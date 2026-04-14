{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE LambdaCase #-}

module RepairEngine
  ( repairIssue
  , repairAll
  , resetNetworkStack
  , forgetNetwork
  ) where

import WifiTypes
import Utils.Command
import Data.Text (Text, pack, unpack)
import Control.Monad (when, forM_)
import System.Info (os)
import System.Directory (getCurrentDirectory)
import Data.List (intercalate)

-- | محرك الإصلاح الرئيسي
repairIssue :: WifiIssue -> IO RepairResult
repairIssue = \case
    NoWifiAdapterFound ->
        return $ RepairFailed "لم يتم العثور على كرت واي فاي. تأكد من تعريفات الجهاز."
        
    AdapterDisabled -> do
        platform <- getOs
        case platform of
            "linux"   -> repairByCommand "rfkill unblock wifi" "تم تفعيل كرت الواي فاي"
            "mingw32" -> repairByCommand "netsh interface set interface \"Wi-Fi\" enabled" "تم تفعيل كرت الواي فاي"
            _         -> return $ RepairNotApplicable
            
    NotConnected -> do
        platform <- getOs
        case platform of
            "linux"   -> repairByCommand "nmcli device wifi rescan" "تم تحديث قائمة الشبكات"
            "mingw32" -> repairByCommand "netsh wlan show networks" "تم تحديث قائمة الشبكات"
            _         -> return $ RepairRequiresUserAction "الرجاء الاتصال يدوياً بالشبكة"
            
    ConnectedNoInternet -> do
        resetNetworkStack
        return $ RepairSuccess "تم إعادة تهيئة مكدس الشبكة. انتظر 10 ثواني."
        
    DnsResolutionFailure -> do
        platform <- getOs
        case platform of
            "linux"   -> flushDnsLinux
            "mingw32" -> flushDnsWindows
            _         -> return ()
        return $ RepairSuccess "تم مسح ذاكرة DNS المؤقتة"
        
    WeakSignalStrength lvl -> 
        return $ RepairRequiresUserAction $ pack $
            "الإشارة ضعيفة (" ++ show lvl ++ "%). يفضل الاقتراب من الراوتر."
            
    WrongPassword ->
        return $ RepairRequiresUserAction "الرجاء نسيان الشبكة وإعادة إدخال كلمة المرور"
        
    IpConflict -> do
        platform <- getOs
        case platform of
            "linux"   -> repairByCommand "sudo dhclient -r && sudo dhclient" "تم تجديد عنوان IP"
            "mingw32" -> repairByCommand "ipconfig /release && ipconfig /renew" "تم تجديد عنوان IP"
            _         -> return $ RepairNotApplicable
            
    DriverIssue ->
        return $ RepairRequiresUserAction "الرجاء تحديث تعريفات كرت الشبكة من موقع الشركة المصنعة"
        
    UnknownError msg ->
        return $ RepairFailed $ "خطأ غير معروف: " <> msg
        
    _ -> return RepairNotApplicable

-- | محاولة إصلاح جميع المشاكل المكتشفة
repairAll :: [WifiIssue] -> IO [RepairResult]
repairAll = mapM repairIssue

-- | إعادة تهيئة كاملة لمكدس الشبكة
resetNetworkStack :: IO ()
resetNetworkStack = do
    platform <- getOs
    case platform of
        "linux" -> do
            runCommand_ "nmcli networking off"
            runCommand_ "sleep 2"
            runCommand_ "nmcli networking on"
        "mingw32" -> do
            runCommand_ "ipconfig /release"
            runCommand_ "ipconfig /renew"
            runCommand_ "ipconfig /flushdns"
        _ -> return ()

-- | نسيان شبكة محفوظة
forgetNetwork :: Text -> IO RepairResult
forgetNetwork ssidText = do
    platform <- getOs
    let ssid = unpack ssidText
    case platform of
        "linux" -> repairByCommand 
            ("nmcli connection delete id \"" ++ ssid ++ "\"") 
            ("تم حذف شبكة " ++ ssid)
        "mingw32" -> repairByCommand
            ("netsh wlan delete profile name=\"" ++ ssid ++ "\"")
            ("تم حذف شبكة " ++ ssid)
        _ -> return $ RepairNotApplicable

-- | دوال مساعدة داخلية
getOs :: IO String
getOs = return os

flushDnsLinux :: IO ()
flushDnsLinux = runCommand_ "sudo systemd-resolve --flush-caches"

flushDnsWindows :: IO ()
flushDnsWindows = runCommand_ "ipconfig /flushdns"

repairByCommand :: String -> String -> IO RepairResult
repairByCommand cmd successMsg = do
    result <- runCommand cmd
    case result of
        Right _  -> return $ RepairSuccess (pack successMsg)
        Left err -> return $ RepairFailed (pack $ "فشل الأمر: " ++ err)
