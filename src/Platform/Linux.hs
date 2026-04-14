{-# LANGUAGE OverloadedStrings #-}

module Platform.Linux
  ( linuxCheckAdapter
  , linuxGetStatus
  , linuxScanNetworks
  ) where

import WifiTypes
import Utils.Command
import Data.Text (Text, pack, strip, lines, words, isInfixOf, breakOn, drop)
import Data.Maybe (listToMaybe)
import Control.Exception (try, SomeException)
import System.Process (readProcess)

linuxCheckAdapter :: IO [WifiIssue]
linuxCheckAdapter = do
    result <- try (readProcess "rfkill" ["list", "wifi"] "") :: IO (Either SomeException String)
    case result of
        Left _ -> return [NoWifiAdapterFound]
        Right output ->
            if "Soft blocked: yes" `isInfixOf` pack output
                then return [AdapterDisabled]
                else return []

linuxGetStatus :: IO NetworkStatus
linuxGetStatus = do
    -- استخدام nmcli للحصول على الحالة
    result <- try (readProcess "nmcli" ["-t", "-f", "GENERAL.CONNECTION,GENERAL.DEVICE,IP4.ADDRESS", "device", "show"] "") 
                :: IO (Either SomeException String)
    
    case result of
        Left _ -> return emptyStatus
        Right output -> parseNmcliOutput (pack output)
  where
    emptyStatus = NetworkStatus
        { ssid = Nothing
        , signalLevel = 0
        , ipAddress = Nothing
        , gateway = Nothing
        , isConnected = False
        , adapterName = Nothing
        , securityType = Nothing
        }
    
    parseNmcliOutput txt = 
        let linesList = Data.Text.lines txt
            connection = extractField "GENERAL.CONNECTION:" linesList
            device = extractField "GENERAL.DEVICE:" linesList
            ipAddr = extractField "IP4.ADDRESS[1]:" linesList
            isConn = connection /= Just "" && connection /= Nothing
        in NetworkStatus
            { ssid = connection
            , signalLevel = 75
            , ipAddress = fmap (takeWhile (/= '/') . unpack) ipAddr >>= \x -> return (pack x)
            , gateway = Nothing
            , isConnected = isConn
            , adapterName = device
            , securityType = Nothing
            }

extractField :: Text -> [Text] -> Maybe Text
extractField prefix = fmap (strip . snd) 
                    . listToMaybe 
                    . filter ((prefix `isInfixOf`) . fst)
                    . map (breakOn ":")
  where
    breakOn sep txt = 
        let (a, b) = Data.Text.breakOn sep txt
        in (a, Data.Text.drop 1 b)

linuxScanNetworks :: IO [AccessPoint]
linuxScanNetworks = do
    result <- try (readProcess "nmcli" ["-t", "-f", "SSID,SIGNAL,SECURITY", "device", "wifi", "list"] "") 
                :: IO (Either SomeException String)
    case result of
        Left _  -> return []
        Right output -> return $ parseWifiList (pack output)
  where
    parseWifiList txt = 
        let networkLines = filter (not . Data.Text.null) (Data.Text.lines txt)
        in map parseLine networkLines
    
    parseLine line =
        case Data.Text.splitOn ":" line of
            [ssid, signal, security] -> AccessPoint
                { apSsid = ssid
                , apSignal = readMaybe (unpack signal) 0
                , apSecurity = security
                , apConnected = False
                }
            _ -> AccessPoint "" 0 "" False

readMaybe :: String -> Int -> Int
readMaybe s def = case reads s of
    [(x, "")] -> x
    _         -> def
