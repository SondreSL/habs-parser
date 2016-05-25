module Main where

import ABS.Parser
import System.Environment (getArgs)
import Control.Monad (when)
import System.Exit (exitFailure)
import System.Directory (doesDirectoryExist)

pathToSampleSubmodule :: String
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
  
  resSamples <- parseFileOrDir samplesDir
  
  let failedSamples = filter (\ resSample -> case resSample of
                               (_,Bad _) -> True
                               _ -> False
                             ) resSamples
  
  mapM_ (\ (fp, Bad errorString) -> do
           putStrLn $ "ABS sample failed to parse: " ++ fp 
           putStrLn errorString
        ) failedSamples
  
  let countFailed = length failedSamples
  let countAll = length resSamples
  putStrLn $ "Successfully parsed:" ++ show (countAll - countFailed) ++ "/" ++ show countAll
  when (countFailed /= 0) exitFailure

