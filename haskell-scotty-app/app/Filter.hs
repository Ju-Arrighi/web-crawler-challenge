module Filter (FilterType(..), parseFilter, applyFilter, wordCount) where

import Data.List (sortBy)
import Data.Ord (comparing, Down(..))
import Data.Text (Text)
import qualified Data.Text as T
import Data.Char (isAlphaNum)
import Scraper (Entry(..))

data FilterType = AllEntries | LongTitles | ShortTitles deriving (Eq, Show)

parseFilter :: Maybe Text -> FilterType
parseFilter (Just "long_titles")  = LongTitles
parseFilter (Just "short_titles") = ShortTitles
parseFilter _                     = AllEntries

wordCount :: Text -> Int
wordCount = length . filter (T.any isAlphaNum) . T.words

applyFilter :: FilterType -> [Entry] -> [Entry]
applyFilter AllEntries  entries = entries
applyFilter LongTitles  entries =
  sortBy (comparing (Down . entryComments)) $
  filter (\e -> wordCount (entryTitle e) > 5) entries
applyFilter ShortTitles entries =
  sortBy (comparing (Down . entryPoints)) $
  filter (\e -> wordCount (entryTitle e) <= 5) entries
