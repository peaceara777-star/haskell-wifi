{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}

module WifiTypes where

import Data.Text (Text)
import GHC.Generics (Generic)
import Data.Aeson (ToJSON, FromJSON)

-- | أنواع منصات التشغيل المدعومة
data Platform = Linux | Windows | MacOS
  deriving (Show, Eq)

-- | أنواع مشاكل الواي فاي المعروفة
data WifiIssue
  = NoWifiAdapterFound
  | AdapterDisabled
  | NotConnected
  | ConnectedNoInternet
  | DnsResolutionFailure
  | WeakSignalStrength Int
  | WrongPassword
  | IpConflict
  | CaptivePortalDetected
  | DriverIssue
  | UnknownError Text
  deriving (Show, Eq, Generic, ToJSON, FromJSON)

-- | نتيجة عملية الإصلاح
data RepairResult
  = RepairSuccess Text
  | RepairFailed Text
  | RepairRequiresUserAction Text
  | RepairNotApplicable
  deriving (Show, Eq, Generic, ToJSON, FromJSON)

-- | حالة الشبكة الحالية
data NetworkStatus = NetworkStatus
  { ssid         :: Maybe Text
  , signalLevel  :: Int
  , ipAddress    :: Maybe Text
  , gateway      :: Maybe Text
  , isConnected  :: Bool
  , adapterName  :: Maybe Text
  , securityType :: Maybe Text
  } deriving (Show, Eq, Generic, ToJSON, FromJSON)

-- | تفاصيل نقطة الوصول
data AccessPoint = AccessPoint
  { apSsid       :: Text
  , apSignal     :: Int
  , apSecurity   :: Text
  , apConnected  :: Bool
  } deriving (Show, Eq, Generic, ToJSON, FromJSON)

-- | إعدادات الإصلاح المتقدمة
data RepairConfig = RepairConfig
  { autoReconnect    :: Bool
  , backupDns        :: [Text]
  , maxRetries       :: Int
  , logLevel         :: LogLevel
  } deriving (Show, Eq)

data LogLevel = Debug | Info | Warning | Error
  deriving (Show, Eq, Enum, Bounded)
