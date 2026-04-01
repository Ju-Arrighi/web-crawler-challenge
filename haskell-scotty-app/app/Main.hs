module Main (main) where

import Web.Scotty (scotty, get, queryParamMaybe, html, liftIO)
import Text.Blaze.Html.Renderer.Text (renderHtml)
import Scraper (fetchEntries)
import Filter (parseFilter, applyFilter)
import View (indexView)

main :: IO ()
main = scotty 3000 $ do
  get "/"        handler
  get "/crawler" handler
  -- get "/" $ do
  --   html "<h1>Hello, World!</h1>"

-- handler :: Web.Scotty.ActionM ()
handler = do
  filterParam <- queryParamMaybe "filter"
  entries     <- liftIO fetchEntries
  let ft       = parseFilter filterParam
      filtered  = applyFilter ft entries
  html $ renderHtml (indexView ft filtered)
