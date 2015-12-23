{-# LANGUAGE LambdaCase #-}
module Main where

import ABS.Parser
import System.Environment (getArgs)
import Control.Monad (when)
import System.Exit (exitFailure)

main :: IO ()
main = do
  args <- getArgs
  when (null args) $ error "USAGE: cabal test --test-option=PATH_TO_abs-samples_DIR"
  res <- parseFileOrDir (head args)
  let failed = filter (\case 
                       (_,Bad _) -> True
                       _ -> False
                      ) res
  mapM_ (\ (fp, Bad errorString) -> do
           putStrLn $ "ABS sample failed to parse: " ++ fp 
           putStrLn errorString
        ) failed
  let countFailed = length failed
  let countAll = length res
  putStrLn $ "Successfully parsed:" ++ show (countAll - countFailed) ++ "/" ++ show countAll
  when (countFailed /= 0) exitFailure

