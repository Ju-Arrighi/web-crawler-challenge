module ScraperSpec (spec) where

import Test.Hspec
import qualified Data.ByteString.Lazy as BL
import Scraper (Entry(..), parseDocument, parseFirstInt)

spec :: Spec
spec = do
  describe "parseFirstInt" $ do
    it "parses a points string" $
      parseFirstInt "42 points" `shouldBe` 42
    it "parses singular point" $
      parseFirstInt "1 point" `shouldBe` 1
    it "parses a comments string" $
      parseFirstInt "123 comments" `shouldBe` 123
    it "returns 0 for an empty string" $
      parseFirstInt "" `shouldBe` 0
    it "returns 0 when there are no digits" $
      parseFirstInt "no digits" `shouldBe` 0
    it "returns 0 for \"discuss\" (HN job post with no comments)" $
      parseFirstInt "discuss" `shouldBe` 0
    it "parses a number with leading zeros" $
      parseFirstInt "007" `shouldBe` 7

  describe "fixture parsing" $ do
    it "parses all 3 entries from the fixture" $ do
      entries <- parseDocument <$> BL.readFile "test/fixtures/hn_row.html"
      length entries `shouldBe` 3

    it "extracts title, points, comments, and rank for a normal entry" $ do
      entries <- parseDocument <$> BL.readFile "test/fixtures/hn_row.html"
      let e = entries !! 0
      entryRank     e `shouldBe` 1
      entryTitle    e `shouldBe` "An Example Title With Six Words Here"
      entryPoints   e `shouldBe` 142
      entryComments e `shouldBe` 37

    it "returns 0 comments for a discuss-style entry" $ do
      entries <- parseDocument <$> BL.readFile "test/fixtures/hn_row.html"
      entryComments (entries !! 1) `shouldBe` 0

    it "returns 0 points for an entry without a score element" $ do
      entries <- parseDocument <$> BL.readFile "test/fixtures/hn_row.html"
      entryPoints (entries !! 2) `shouldBe` 0
