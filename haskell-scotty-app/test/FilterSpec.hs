module FilterSpec (spec) where

import Test.Hspec
import Test.Hspec.QuickCheck (prop)
import Test.QuickCheck (Arbitrary(..))
import qualified Data.Text as T
import Filter (FilterType(..), parseFilter, applyFilter, wordCount)
import Scraper (Entry(..))

instance Arbitrary Entry where
  arbitrary = Entry <$> arbitrary <*> (T.pack <$> arbitrary) <*> arbitrary <*> arbitrary

spec :: Spec
spec = do
  describe "parseFilter" $ do
    it "returns AllEntries for Nothing" $
      parseFilter Nothing `shouldBe` AllEntries
    it "returns LongTitles for \"long_titles\"" $
      parseFilter (Just "long_titles") `shouldBe` LongTitles
    it "returns ShortTitles for \"short_titles\"" $
      parseFilter (Just "short_titles") `shouldBe` ShortTitles
    it "returns AllEntries for an unknown value" $
      parseFilter (Just "unknown") `shouldBe` AllEntries
    it "returns AllEntries for an empty string" $
      parseFilter (Just "") `shouldBe` AllEntries

  describe "wordCount" $ do
    it "returns 0 for an empty string" $
      wordCount "" `shouldBe` 0
    it "returns 1 for a single word" $
      wordCount "hello" `shouldBe` 1
    it "counts multiple words correctly" $
      wordCount "one two three" `shouldBe` 3
    it "handles extra whitespace" $
      wordCount "  spaced  out  " `shouldBe` 2
    it "returns 0 for pure punctuation tokens" $
      wordCount "--- ..." `shouldBe` 0
    it "counts a 6-word title as 6" $
      wordCount "one two three four five six" `shouldBe` 6
    it "counts a 5-word title as 5" $
      wordCount "one two three four five" `shouldBe` 5

  describe "applyFilter" $ do
    let short1 = Entry 1 "Short Title"                         100  10
        short2 = Entry 2 "Another Short One"                    50  20
        long1  = Entry 3 "This Is A Long Enough Title Here"     30 200
        long2  = Entry 4 "Another Long Title With Many Words"   20  80
        corpus = [short1, short2, long1, long2]

    describe "AllEntries" $ do
      it "returns all entries in original order" $
        applyFilter AllEntries corpus `shouldBe` corpus
      it "returns empty list for empty input" $
        applyFilter AllEntries [] `shouldBe` []

    describe "LongTitles" $ do
      it "only includes entries with more than 5 words" $
        map entryRank (applyFilter LongTitles corpus) `shouldMatchList` [3, 4]
      it "sorts by comments descending" $
        map entryComments (applyFilter LongTitles corpus) `shouldBe` [200, 80]
      it "returns empty list for empty input" $
        applyFilter LongTitles [] `shouldBe` []
      it "returns empty list when no entries have long titles" $
        applyFilter LongTitles [short1, short2] `shouldBe` []

    describe "ShortTitles" $ do
      it "only includes entries with 5 words or fewer" $
        map entryRank (applyFilter ShortTitles corpus) `shouldMatchList` [1, 2]
      it "sorts by points descending" $
        map entryPoints (applyFilter ShortTitles corpus) `shouldBe` [100, 50]
      it "returns empty list for empty input" $
        applyFilter ShortTitles [] `shouldBe` []
      it "returns empty list when no entries have short titles" $
        applyFilter ShortTitles [long1, long2] `shouldBe` []

    prop "AllEntries preserves list length" $ \es ->
      length (applyFilter AllEntries es) == length (es :: [Entry])
