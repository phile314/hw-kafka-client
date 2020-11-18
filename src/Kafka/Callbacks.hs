module Kafka.Callbacks
( errorCallback
, logCallback
, statsCallback
)
where

import Kafka.Internal.RdKafka (rdKafkaConfSetErrorCb, rdKafkaConfSetLogCb, rdKafkaConfSetStatsCb)
import Kafka.Internal.Setup (HasKafkaConf(..), getRdKafkaConf, Callback(..))
import Kafka.Types (KafkaError(..), KafkaLogLevel(..))

-- | Add a callback for errors.
--
-- ==== __Examples__
--
-- Basic usage:
--
-- > 'setCallback' ('errorCallback' myErrorCallback)
-- >
-- > myErrorCallback :: 'KafkaError' -> String -> IO ()
-- > myErrorCallback kafkaError message = print $ show kafkaError <> "|" <> message
errorCallback :: (KafkaError -> String -> IO ()) -> Callback
errorCallback callback =
  let realCb _ err = callback (KafkaResponseError err)
  in Callback $ \k -> rdKafkaConfSetErrorCb (getRdKafkaConf k) realCb

-- | Add a callback for logs.
--
-- ==== __Examples__
--
-- Basic usage:
--
-- > 'setCallback' ('logCallback' myLogCallback)
-- >
-- > myLogCallback :: 'KafkaLogLevel' -> String -> String -> IO ()
-- > myLogCallback level facility message = print $ show level <> "|" <> facility <> "|" <> message
logCallback :: (KafkaLogLevel -> String -> String -> IO ()) -> Callback
logCallback callback =
  let realCb _ = callback . toEnum
  in Callback $ \k -> rdKafkaConfSetLogCb (getRdKafkaConf k) realCb

-- | Add a callback for stats.
--
-- ==== __Examples__
--
-- Basic usage:
--
-- > 'setCallback' ('statsCallback' myStatsCallback)
-- >
-- > myStatsCallback :: String -> IO ()
-- > myStatsCallback stats = print $ show stats
statsCallback :: (String -> IO ()) -> Callback
statsCallback callback =
  let realCb _ = callback
  in Callback $ \k -> rdKafkaConfSetStatsCb (getRdKafkaConf k) realCb
