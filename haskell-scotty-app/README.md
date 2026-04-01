# HN Crawler — Haskell / Scotty

A Haskell web crawler that scrapes the top 30 entries from [Hacker News](https://news.ycombinator.com/) and serves them through a small web interface with three filter views. Built with [Scotty](https://github.com/scotty-web/scotty) and rendered with Blaze HTML + Tailwind CSS.

This is the Haskell implementation of the multi-language web crawler challenge. The test suite uses [HSpec](https://hspec.github.io/), mirroring the RSpec style of the Ruby version.

---

## Prerequisites

Install [ghcup](https://www.haskell.org/ghcup/) and use it to install the exact versions below:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
ghcup install ghc 9.14.1
ghcup set ghc 9.14.1
ghcup install cabal 3.16.1.0
ghcup set cabal 3.16.1.0
```

| Tool | Version |
|---|---|
| GHC | 9.14.1 |
| cabal-install | 3.16.1.0 |

> **Note:** GHC 9.14.1 is recent and many Hackage packages have stale upper bounds against its `template-haskell 2.24` and `time 1.15`. `allow-newer: all` in `cabal.project` handles this automatically — no action needed.
> Scotty is pinned to `== 0.22` because 0.30 does not compile on GHC 9.14.1.

---

## Getting Started

```bash
git clone <repo-url>
cd haskell-scotty-app
cabal update        # refresh the Hackage package index
cabal build         # downloads and compiles all dependencies
cabal run           # starts the server on port 3000
```

Open `http://localhost:3000` in your browser.

---

## Usage

The app exposes three views via a `filter` query parameter:

| URL | Description |
|---|---|
| `http://localhost:3000/` | All 30 entries, original HN order |
| `http://localhost:3000/?filter=long_titles` | Titles with > 5 words, sorted by comments ↓ |
| `http://localhost:3000/?filter=short_titles` | Titles with ≤ 5 words, sorted by points ↓ |

The same views are also available at `/crawler`.

**Word count rule:** only tokens containing at least one alphanumeric character are counted. Punctuation-only tokens (e.g. `---`, `...`) are ignored.

---

## Running Tests

```bash
cabal test --test-show-details=streaming
```

Expected output: **34 examples, 0 failures**

### What is tested

**`FilterSpec`** (`test/FilterSpec.hs`)
- `parseFilter` — 5 cases: `Nothing`, known values, unknown/empty strings
- `wordCount` — 7 cases: empty string, single word, multiple words, extra whitespace, punctuation-only tokens, boundary values (5 and 6 words)
- `applyFilter` — all 3 filter types with corpus + edge cases (empty list, all-short, all-long), plus a QuickCheck property that runs 100 random inputs

**`ScraperSpec`** (`test/ScraperSpec.hs`)
- `parseFirstInt` — 7 cases including the `"discuss"` edge case (HN job posts that have no comments)
- Fixture-based HTML parsing — loads `test/fixtures/hn_row.html` and asserts title, points, comments, and rank for 3 representative entries (normal, discuss-style, no-score)

Tests are auto-discovered by `hspec-discover` — any file matching `test/**/*Spec.hs` is picked up automatically.

---

## Project Structure

```
app/
  Main.hs               — Scotty routes; wires scraper, filter, and view together
  Scraper.hs            — HTTP fetch + HTML parsing via xml-conduit cursor API
  Filter.hs             — Pure filtering and sorting logic
  View.hs               — Blaze HTML rendering
test/
  Spec.hs               — hspec-discover entry point (one-liner)
  FilterSpec.hs         — Tests for Filter module
  ScraperSpec.hs        — Tests for Scraper module
  fixtures/
    hn_row.html         — Minimal HN HTML used for parsing tests
haskell-scotty-app.cabal
cabal.project
```

---

## Key Dependencies

| Package | Version | Purpose |
|---|---|---|
| scotty | 0.22 | Web framework |
| warp | 3.4.12 | HTTP server (used by Scotty) |
| http-conduit | 2.3.9.1 | HTTP client for fetching HN |
| html-conduit | 1.3.2.2 | Lenient HTML → XML parsing |
| xml-conduit | 1.10.1.0 | XML cursor API for tree traversal |
| blaze-html | 0.9.2.0 | Type-safe HTML generation |
| hspec | 2.11.17 | Test framework (RSpec-style) |
| QuickCheck | 2.18.0.0 | Property-based testing |

Tailwind CSS is loaded from CDN at runtime — no build step or Node.js required.

---

## Design Notes

**GHC 9.14.1 compatibility**
GHC 9.14.1 ships `template-haskell 2.24` and `time 1.15`, which are newer than the upper bounds declared by many transitive dependencies (notably `aeson`). `allow-newer: all` in `cabal.project` globally relaxes these conservative bounds. The packages themselves compile and run correctly despite the declared upper bounds.

---

## License

BSD-3-Clause © Juliana Arrighi
