{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE LambdaCase #-}

module Main where

import WifiTypes
import Diagnostics
import RepairEngine
import Data.Text (Text, pack, unpack)
import qualified Data.Text.IO as TIO
import System.Environment (getArgs)
import System.Exit (exitSuccess, exitFailure)
import Control.Monad (forM_, when)

main :: IO ()
main = do
    args <- getArgs
    case args of
        []                    -> interactiveMode
        ["--diagnose"]        -> diagnoseMode
        ["--repair"]          -> repairMode
        ["--scan"]            -> scanMode
        ["--status"]          -> statusMode
        ["--help"]            -> printHelp
        ["--version"]         -> printVersion
        ["--reset-network"]   -> resetNetworkStack >> putStrLn "✅ تم إعادة تهيئة الشبكة"
        ["--forget", ssid]    -> forgetNetwork (pack ssid) >>= printResult
        _                     -> printHelp >> exitFailure

-- | وضع التشغيل التفاعلي (افتراضي)
interactiveMode :: IO ()
interactiveMode = do
    putHeader "المحلل الاحترافي للواي فاي"
    putStrLn "جاري فحص البيئة...\n"
    
    issues <- diagnoseIssue
    
    if null issues
        then putStrLn "✅ الشبكة تعمل بكفاءة عالية. لا توجد أعطال مكتشفة."
        else do
            putStrLn "⚠️ تم اكتشاف المشاكل التالية:\n"
            forM_ issues $ \issue ->
                putStrLn $ "  • " ++ show issue
            
            putStr "\n🔧 هل تريد محاولة الإصلاح التلقائي؟ (y/n): "
            answer <- getLine
            when (answer == "y" || answer == "Y") $ do
                putStrLn "\n⏳ جاري الإصلاح...\n"
                results <- repairAll issues
                forM_ results printResult
    
    putStrLn "\n✨ اكتمل التحليل."

-- | وضع التشخيص فقط
diagnoseMode :: IO ()
diagnoseMode = do
    issues <- diagnoseIssue
    if null issues
        then putStrLn "NO_ISSUES"
        else mapM_ (putStrLn . show) issues

-- | وضع الإصلاح التلقائي
repairMode :: IO ()
repairMode = do
    issues <- diagnoseIssue
    results <- repairAll issues
    mapM_ printResult results

-- | مسح الشبكات المتاحة
scanMode :: IO ()
scanMode = do
    putStrLn "📡 جاري مسح الشبكات المتاحة...\n"
    networks <- scanNetworks
    if null networks
        then putStrLn "❌ لم يتم العثور على شبكات"
        else do
            putStrLn "📶 الشبكات المكتشفة:\n"
            forM_ networks $ \ap -> do
                let signalBar = replicate (apSignal ap `div` 20) '█'
                putStrLn $ "  • " ++ unpack (apSsid ap) ++ 
                          " [" ++ signalBar ++ "] " ++ 
                          show (apSignal ap) ++ "%"

-- | عرض حالة الشبكة الحالية
statusMode :: IO ()
statusMode = do
    status <- getNetworkStatus
    putStrLn "📊 حالة الشبكة الحالية:"
    putStrLn $ "  SSID:        " ++ show (ssid status)
    putStrLn $ "  الإشارة:     " ++ show (signalLevel status) ++ "%"
    putStrLn $ "  IP:          " ++ show (ipAddress status)
    putStrLn $ "  البوابة:     " ++ show (gateway status)
    putStrLn $ "  متصل:        " ++ show (isConnected status)

-- | طباعة نتيجة الإصلاح
printResult :: RepairResult -> IO ()
printResult = \case
    RepairSuccess msg         -> putStrLn $ "✅ " ++ unpack msg
    RepairFailed msg          -> putStrLn $ "❌ " ++ unpack msg
    RepairRequiresUserAction msg -> putStrLn $ "🔧 " ++ unpack msg
    RepairNotApplicable       -> return ()

-- | رأس التطبيق
putHeader :: String -> IO ()
putHeader title = do
    putStrLn $ replicate 50 "="
    putStrLn $ "  " ++ title
    putStrLn $ replicate 50 "="
    putStrLn ""

-- | معلومات المساعدة
printHelp :: IO ()
printHelp = do
    putStrLn $ unlines
        [ "استخدام: wifi-diagnostic [خيارات]"
        , ""
        , "خيارات:"
        , "  (بدون خيارات)      وضع تفاعلي مع تشخيص وإصلاح"
        , "  --diagnose         تشخيص المشاكل فقط"
        , "  --repair           إصلاح تلقائي لجميع المشاكل"
        , "  --scan             مسح الشبكات المتاحة"
        , "  --status           عرض حالة الشبكة الحالية"
        , "  --reset-network    إعادة تهيئة مكدس الشبكة"
        , "  --forget SSID      حذف شبكة محفوظة"
        , "  --help             عرض هذه المساعدة"
        , "  --version          عرض رقم الإصدار"
        , ""
        , "أمثلة:"
        , "  wifi-diagnostic"
        , "  wifi-diagnostic --scan"
        , "  wifi-diagnostic --forget \"MyWiFi\""
        ]

-- | رقم الإصدار
printVersion :: IO ()
printVersion = putStrLn "wifi-diagnostic version 1.0.0"
