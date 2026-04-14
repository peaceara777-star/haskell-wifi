{-# LANGUAGE OverloadedStrings #-}

module Diagnostics
  ( diagnoseIssue
  , getNetworkStatus
  , scanNetworks
  , checkInternetConnectivity
  ) where

import WifiTypes
import Platform.Linux (linuxCheckAdapter, linuxGetStatus, linuxScanNetworks)
import Platform.Windows (windowsCheckAdapter, windowsGetStatus, windowsScanNetworks)
import System.Info (os)
import Data.Text (Text)
import Control.Exception (try, SomeException)
import System.Process (readProcess)
import Data.Text (pack, isInfixOf)

-- | الدالة الرئيسية: تحلل الحالة وترجع قائمة بالمشاكل المحتملة
diagnoseIssue :: IO [WifiIssue]
diagnoseIssue = do
    platform <- getPlatform
    adapterIssues <- checkAdapter platform
    connectionIssues <- checkConnection
    dnsIssues <- checkDns
    
    return $ concat [adapterIssues, connectionIssues, dnsIssues]

-- | تحديد نظام التشغيل الحالي
getPlatform :: IO Platform
getPlatform = case os of
    "linux"   -> return Linux
    "mingw32" -> return Windows
    "mingw64" -> return Windows
    "darwin"  -> return MacOS
    _         -> return Linux  -- افتراضي

-- | فحص حالة كرت الشبكة حسب النظام
checkAdapter :: Platform -> IO [WifiIssue]
checkAdapter Linux   = linuxCheckAdapter
checkAdapter Windows = windowsCheckAdapter
checkAdapter MacOS   = return []  -- لم ينفذ بعد

-- | الحصول على حالة الشبكة الكاملة
getNetworkStatus :: IO NetworkStatus
getNetworkStatus = do
    platform <- getPlatform
    case platform of
        Linux   -> linuxGetStatus
        Windows -> windowsGetStatus
        MacOS   -> return emptyStatus
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

-- | مسح الشبكات المتاحة
scanNetworks :: IO [AccessPoint]
scanNetworks = do
    platform <- getPlatform
    case platform of
        Linux   -> linuxScanNetworks
        Windows -> windowsScanNetworks
        MacOS   -> return []

-- | فحص جودة الاتصال
checkConnection :: IO [WifiIssue]
checkConnection = do
    -- فحص اتصال بالبوابة (Gateway)
    pingGateway <- tryPing "8.8.8.8"  -- نفحص DNS جوجل مباشرة
    
    let issues = case pingGateway of
            Left _        -> [NotConnected]
            Right output  -> 
                if "0% packet loss" `isInfixOf` pack output
                    then []
                    else [WeakSignalStrength 30]
    return issues

-- | فحص DNS
checkDns :: IO [WifiIssue]
checkDns = do
    result <- try $ readProcess "nslookup" ["google.com"] ""
    case result of
        Left (_ :: SomeException) -> return [DnsResolutionFailure]
        Right _                   -> return []

-- | فحص الاتصال بالإنترنت (Google DNS)
checkInternetConnectivity :: IO Bool
checkInternetConnectivity = do
    result <- tryPing "8.8.8.8"
    case result of
        Right out -> return $ "0% packet loss" `isInfixOf` pack out
        Left _    -> return False

-- | مساعد: تنفيذ ping
tryPing :: String -> IO (Either SomeException String)
tryPing host = try $ readProcess "ping" ["-c", "2", "-W", "1", host] ""
