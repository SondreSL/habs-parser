{-# LANGUAGE LambdaCase #-}
module Main where

import ABS.Parser
import System.Environment (getArgs)
import Control.Monad (when)
import System.Exit (exitFailure)
import System.Directory (doesDirectoryExist)

pathToSampleSubmodule = "./habs-samples"

main :: IO ()
main = do
  -- determine the path to the ABS sample source files (for parsing them) 
  samplesDir <- do
         argv <- getArgs
         if null argv
          then do
           b <- doesDirectoryExist pathToSampleSubmodule
           if b
            then return pathToSampleSubmodule
            else error "USAGE: git submodule update --init; cabal test *OR* cabal test --test-option=PATH_TO_abs-samples_DIR"
          else return $ head argv
  res <- parseFileOrDir samplesDir
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

