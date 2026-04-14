{-# LANGUAGE OverloadedStrings #-}

module Platform.Windows
  ( windowsCheckAdapter
  , windowsGetStatus
  , windowsScanNetworks
  ) where

import WifiTypes
import Utils.Command
import Data.Text (Text, pack, strip, lines, isInfixOf)
import Control.Exception (try, SomeException)
import System.Process (readProcess)

windowsCheckAdapter :: IO [WifiIssue]
windowsCheckAdapter = do
    result <- try (readProcess "netsh" ["wlan", "show", "interfaces"] "") 
                :: IO (Either SomeException String)
    case result of
        Left _ -> return [NoWifiAdapterFound]
        Right output ->
            if "State" `isInfixOf` pack output
                then 
                    if "disconnected" `isInfixOf` pack (map toLower output)
                        then return []
                        else return []
                else return [AdapterDisabled]

windowsGetStatus :: IO NetworkStatus
windowsGetStatus = do
    result <- try (readProcess "netsh" ["wlan", "show", "interfaces"] "")
                :: IO (Either SomeException String)
    case result of
        Left _ -> return emptyStatus
        Right output -> return $ parseNetshOutput (pack output)
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
    
    parseNetshOutput txt =
        let linesList = Data.Text.lines txt
            ssidLine = findLine "SSID" linesList
            signalLine = findLine "Signal" linesList
            stateLine = findLine "State" linesList
            isConn = case stateLine of
                Just s -> "connected" `isInfixOf` Data.Text.toLower s
                Nothing -> False
            signal = case signalLine of
                Just s -> extractPercent s
                Nothing -> 0
        in NetworkStatus
            { ssid = fmap (strip . snd . breakOn ":") ssidLine
            , signalLevel = signal
            , ipAddress = Nothing
            , gateway = Nothing
            , isConnected = isConn
            , adapterName = Just "Wi-Fi"
            , securityType = Nothing
            }

windowsScanNetworks :: IO [AccessPoint]
windowsScanNetworks = do
    result <- try (readProcess "netsh" ["wlan", "show", "networks", "mode=Bssid"] "")
                :: IO (Either SomeException String)
    case result of
        Left _  -> return []
        Right output -> return $ parseNetshNetworks (pack output)
  where
    parseNetshNetworks txt = 
        let networkBlocks = Data.Text.splitOn "SSID" txt
        in map parseBlock (drop 1 networkBlocks)
    
    parseBlock block =
        let linesList = Data.Text.lines block
            ssid = case linesList of
                (x:_) -> strip $ snd $ breakOn ":" x
                _     -> ""
            signalLine = findLine "Signal" linesList
            signal = case signalLine of
                Just s -> extractPercent s
                Nothing -> 0
        in AccessPoint
            { apSsid = ssid
            , apSignal = signal
            , apSecurity = "WPA2"
            , apConnected = False
            }

-- دوال مساعدة
breakOn :: Text -> Text -> (Text, Text)
breakOn sep txt = 
    let (a, b) = Data.Text.breakOn sep txt
    in (a, Data.Text.drop 1 b)

findLine :: Text -> [Text] -> Maybe Text
findLine pattern = listToMaybe . filter (pattern `isInfixOf`)

extractPercent :: Text -> Int
extractPercent txt =
    let digits = filter (\c -> c >= '0' && c <= '9') (unpack txt)
    in case reads digits of
        [(n, "")] -> n
        _         -> 0

listToMaybe :: [a] -> Maybe a
listToMaybe []    = Nothing
listToMaybe (x:_) = Just x
