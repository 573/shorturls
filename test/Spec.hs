{-# LANGUAGE OverloadedStrings, QuasiQuotes #-}
module Main (main) where

import qualified Database.Redis as Hedis

main :: IO (Either Hedis.Reply Hedis.Status)
main = do
  conn <- Hedis.connect Hedis.defaultConnectInfo
  Hedis.runRedis conn Hedis.ping

