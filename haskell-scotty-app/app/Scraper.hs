module Scraper (Entry(..), fetchEntries) where

import Data.Text (Text)
import qualified Data.Text as T
import qualified Data.Text.Encoding as TE
import Data.Char (isDigit)
import Data.Maybe (listToMaybe, fromMaybe)
import Network.HTTP.Simple (httpLBS, parseRequest, getResponseBody)
import Text.HTML.DOM (parseLBS)
import Text.XML.Cursor
  ( Cursor, fromDocument, element, attributeIs, attribute, check, content
  , ($//), ($/), (&//), (&/)
  , following, node
  )
import qualified Text.XML as XML

data Entry = Entry
  { entryRank     :: Int
  , entryTitle    :: Text
  , entryPoints   :: Int
  , entryComments :: Int
  } deriving (Show, Eq)

fetchEntries :: IO [Entry]
fetchEntries = do
  request  <- parseRequest "https://news.ycombinator.com/"
  response <- httpLBS request
  let doc    = parseLBS (getResponseBody response)
      cursor = fromDocument doc
      athings = cursor $// element "tr" >=> check (\c -> any ("athing" `T.isInfixOf`) (attribute "class" c))
  return $ take 30 $ zipWith parseRow [1..] athings

parseRow :: Int -> Cursor -> Entry
parseRow i athingCursor =
  Entry
    { entryRank     = i
    , entryTitle    = extractTitle athingCursor
    , entryPoints   = extractPoints subtextCursor
    , entryComments = extractComments subtextCursor
    }
  where
    subtextCursor = firstFollowingTr athingCursor

firstFollowingTr :: Cursor -> Maybe Cursor
firstFollowingTr c =
  listToMaybe
    [ fc
    | fc <- following c
    , case node fc of
        XML.NodeElement el -> XML.nameLocalName (XML.elementName el) == "tr"
        _                  -> False
    ]

extractTitle :: Cursor -> Text
extractTitle c =
  fromMaybe "" . listToMaybe $
    c $// (attributeIs "class" "titleline") &/ element "a" &// content

extractPoints :: Maybe Cursor -> Int
extractPoints Nothing  = 0
extractPoints (Just c) =
  parseFirstInt . fromMaybe "" . listToMaybe $
    c $// (attributeIs "class" "score") &// content

extractComments :: Maybe Cursor -> Int
extractComments Nothing  = 0
extractComments (Just c) =
  let links = c $// element "a" &// content
  in  case reverse links of
        (t:_) -> parseFirstInt t
        []    -> 0

parseFirstInt :: Text -> Int
parseFirstInt t =
  let digits = T.takeWhile isDigit . T.dropWhile (not . isDigit) $ t
  in  if T.null digits then 0 else read (T.unpack digits)

-- Helper: combine two cursor axes
(>=>) :: (Cursor -> [Cursor]) -> (Cursor -> [Cursor]) -> Cursor -> [Cursor]
f >=> g = \c -> concatMap g (f c)
