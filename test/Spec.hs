module Main where

import Test.Hspec
import WifiTypes
import Diagnostics (diagnoseIssue)

main :: IO ()
main = hspec $ do
    describe "WiFi Diagnostic System" $ do
        it "يمكن تشغيل التشخيص بدون أخطاء" $ do
            issues <- diagnoseIssue
            length issues `shouldSatisfy` (>= 0)
        
        it "أنواع المشاكل معرفة بشكل صحيح" $ do
            show NoWifiAdapterFound `shouldBe` "NoWifiAdapterFound"
            show ConnectedNoInternet `shouldBe` "ConnectedNoInternet"
        
        it "هيكل NetworkStatus صحيح" $ do
            let status = NetworkStatus
                    { ssid = Just "MyWiFi"
                    , signalLevel = 80
                    , ipAddress = Just "192.168.1.100"
                    , gateway = Just "192.168.1.1"
                    , isConnected = True
                    , adapterName = Just "wlan0"
                    , securityType = Just "WPA2"
                    }
            isConnected status `shouldBe` True
            signalLevel status `shouldBe` 80
