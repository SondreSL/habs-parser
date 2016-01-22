-- | The parse phase as a top-level command to be called by the main compiler module.
module ABS.Parser 
    ( parseString 
    , parseFile
    , parseDir
    , parseFileOrDir
    , Err (..)
    ) where

import qualified ABS.AST as ABS
import BNFC_Gen.ParABS
import BNFC_Gen.ErrM
import Control.Monad (filterM)
import System.Directory (doesFileExist, doesDirectoryExist, getDirectoryContents)
import System.FilePath ((</>))
import Data.List (isSuffixOf)
import Control.Exception (try,IOException)

-- | Parses a String containing the ABS code to an AST
parseString :: String -> Err ABS.Program
parseString input = case pProgram (myLexer input) of -- calling the generated lexer & parser
                      Bad errorString -> Bad $ "Error in parsing:\n" ++ errorString
                      ok -> ok

-- | Parse a single ABS source file
-- 
-- it is exception-safe, i.e. catches any file-IO exceptions
parseFile :: FilePath -> IO (FilePath, Err ABS.Program)
parseFile absFileName = do
 res <- if absFileName `isSuffixOf` ".abs" 
       then return $ Bad "The ABS filename must end with .abs suffix"
       else doesFileExist absFileName >>= \ absFileExists ->
           if absFileExists
           then do
             mAbsCode <- try $ readFile absFileName :: IO (Either IOException String)
             return $ case mAbsCode of
                        Left _ -> Bad $ "IO error on abs file"
                        Right absCode -> parseString absCode
           else return $ Bad "abs file does not exist"
 return (absFileName, res)

-- | Parse all ABS files under directory and its subdirectories recursively.
-- 
-- it is exception-safe, i.e. ignores any dirs it cannot read (no access or IO error)
parseDir :: FilePath -> IO [(FilePath, Err ABS.Program)]
parseDir pwd = do
  mls <- try $ getDirectoryContents pwd :: IO (Either IOException [FilePath])
  case mls of
    Left _ -> return []
    Right ls -> do
             -- parse all AbsFiles under current-dir 
             let absFileNames = filter (isSuffixOf ".abs") ls
             pwdRes <- mapM (\ relativeABSFileName -> 
                                parseFile (pwd </> relativeABSFileName)
                           ) absFileNames

             -- deep-recurse to all subdirs
             subDirs <- filterM (\ mdir -> if mdir == "." || mdir == ".." -- we have to exclude this in unix
                                         then return False
                                         else doesDirectoryExist (pwd </> mdir)) ls
             subRes <- mapM (\ relativeSubDir -> 
                                parseDir (pwd </> relativeSubDir)
                           ) subDirs
             return (pwdRes ++ concat subRes)


-- | Helper top-level function to parse either an ABS source file or a directory recursively.
--
parseFileOrDir :: FilePath -> IO [(FilePath, Err ABS.Program)]
parseFileOrDir fp = doesDirectoryExist fp >>= \ isdir -> if isdir
                                                        then parseDir fp
                                                        else return . return =<< parseFile fp

