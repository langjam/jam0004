module Main (main) where

import System.Directory (doesFileExist)
import System.Environment (getArgs)
import TwoHand (report)

main :: IO ()
main =
  getArgs >>= \case
    filename : _ -> do
      doesFileExist filename >>= \case
        True -> do
          s <- readFile filename
          putStrLn $ report s
        False -> putStrLn "no such file exists"
    _ -> putStrLn "please supply a file"
