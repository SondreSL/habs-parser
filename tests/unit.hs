module Main where

import ABS.Parser

import Test.Tasty
import Test.Tasty.HUnit
import Test.Tasty.Runners.Html

import System.Directory (doesDirectoryExist)
import Control.Monad (unless)

pathToSampleSubmodule :: String
pathToSampleSubmodule = "habs-samples"

main :: IO ()
main = do

  b <- doesDirectoryExist pathToSampleSubmodule
  unless b $ error "missing habs-samples, run: git submodule update --init; cabal test"
                
  resSamples <- parseFileOrDir pathToSampleSubmodule

  defaultMainWithIngredients (htmlRunner:defaultIngredients) $
    testGroup "parse" (map (\ (fp, resCode) -> testCase fp $ case resCode of
                                                              Bad msg -> assertFailure msg
                                                              Ok _ast -> return () ) resSamples)
