{-# LANGUAGE OverloadedStrings #-}

module Utils.Command
  ( runCommand
  , runCommand_
  , runCommandWithTimeout
  ) where

import System.Process (readProcess, callCommand)
import Control.Exception (try, SomeException)
import Data.Text (Text, pack)

-- | تشغيل أمر نظام وإرجاع النتيجة
runCommand :: String -> IO (Either String String)
runCommand cmd = do
    result <- try (readProcess "sh" ["-c", cmd] "") :: IO (Either SomeException String)
    case result of
        Right out -> return $ Right out
        Left  err -> return $ Left (show err)

-- | تشغيل أمر بدون انتظار النتيجة
runCommand_ :: String -> IO ()
runCommand_ cmd = callCommand cmd

-- | تشغيل أمر مع مهلة زمنية (للأوامر التي قد تعلق)
runCommandWithTimeout :: Int -> String -> IO (Either String String)
runCommandWithTimeout seconds cmd = do
    result <- try $ readProcess "timeout" [show seconds, "sh", "-c", cmd] ""
    case result of
        Right out -> return $ Right out
        Left  err -> return $ Left (show err)
