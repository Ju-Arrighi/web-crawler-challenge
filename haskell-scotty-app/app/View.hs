module View (indexView) where

import Data.Text (Text)
import qualified Data.Text as T
import Text.Blaze.Html5 (Html, (!))
import qualified Text.Blaze.Html5 as H
import qualified Text.Blaze.Html5.Attributes as A
import Scraper (Entry(..))
import Filter (FilterType(..))

indexView :: FilterType -> [Entry] -> Html
indexView ft entries = H.docTypeHtml $ do
  H.head $ do
    H.meta ! A.charset "utf-8"
    H.title "HN Crawler"
    H.script ! A.src "https://cdn.tailwindcss.com" $ mempty
  H.body ! A.class_ "bg-gray-50 p-8" $ do
    H.h1 ! A.class_ "text-3xl font-bold mb-6" $ "Hacker News — Top 30"
    filterNav ft
    H.p ! A.class_ "text-sm text-gray-500 mb-4" $
      H.toHtml (show (length entries) ++ " entries shown")
    entriesTable entries

filterNav :: FilterType -> Html
filterNav active = H.div ! A.class_ "flex gap-3 mb-6" $ do
  navLink AllEntries  active "/"                             "All entries"
  navLink LongTitles  active "/?filter=long_titles"         "Long titles (>5 words) · by comments"
  navLink ShortTitles active "/?filter=short_titles"        "Short titles (≤5 words) · by points"

navLink :: FilterType -> FilterType -> Text -> Text -> Html
navLink target active href label =
  H.a ! A.href (H.toValue href) ! A.class_ (H.toValue cls) $ H.toHtml label
  where
    cls :: Text
    cls = if target == active
          then "px-3 py-1 rounded bg-orange-500 text-white text-sm font-medium"
          else "px-3 py-1 rounded bg-gray-200 text-gray-700 text-sm font-medium hover:bg-gray-300"

entriesTable :: [Entry] -> Html
entriesTable entries =
  H.table ! A.class_ "w-full text-sm border-collapse" $ do
    H.thead $
      H.tr ! A.class_ "bg-gray-800 text-white text-left" $ do
        H.th ! A.class_ "px-3 py-2 w-10" $ "#"
        H.th ! A.class_ "px-3 py-2"      $ "Title"
        H.th ! A.class_ "px-3 py-2 text-right w-20" $ "Points"
        H.th ! A.class_ "px-3 py-2 text-right w-24" $ "Comments"
    H.tbody ! A.class_ "divide-y divide-gray-200" $
      mapM_ entryRow (zip [0 :: Int ..] entries)

entryRow :: (Int, Entry) -> Html
entryRow (i, e) =
  H.tr ! A.class_ (H.toValue rowCls) $ do
    H.td ! A.class_ "px-3 py-2 text-gray-400" $ H.toHtml (entryRank e)
    H.td ! A.class_ "px-3 py-2"               $ H.toHtml (entryTitle e)
    H.td ! A.class_ "px-3 py-2 text-right"    $ H.toHtml (entryPoints e)
    H.td ! A.class_ "px-3 py-2 text-right"    $ H.toHtml (entryComments e)
  where
    rowCls :: Text
    rowCls = if odd i
             then "bg-gray-100 hover:bg-gray-200"
             else "bg-white hover:bg-gray-50"
