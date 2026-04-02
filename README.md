# Web Crawler Challenge

This repository contains two independent implementations of the same challenge: a web crawler that fetches and displays the top 30 stories from Hacker News with filtering and sorting.

One app is built in Ruby — a language I know well. The other is in Haskell — a language I had never written before. The intent was to show that I'm language agnostic and genuinely driven by learning. Being willing to step into unfamiliar territory and produce something structured and functional is part of what draws me to this role.

## Repository Structure

```
web-crawler-challenge/
├── ruby-rails-app/        # Rails 8 implementation
└── haskell-scotty-app/    # Haskell + Scotty implementation
```

Each folder has its own README with setup instructions, commands, and architecture notes.

## Why Two Implementations?

The Ruby version reflects how I work when I'm comfortable with the tools — clean architecture, idiomatic code, test coverage.

The Haskell version is a deliberate step outside that comfort zone. It's my first contact with the language. The goal wasn't to produce a polished Haskell app but to demonstrate that I can pick up an unfamiliar language, reason about its constraints, and deliver something coherent.

## Technology Choices

### Ruby — Rails 8

Rails is where I'm most productive. Choosing it shows how I work in a familiar environment.

In hindsight, Sinatra would have been the more appropriate choice here — the app has no database, and Rails carries conventions and dependencies that assume persistence. Removing the DB from a Rails app creates friction rather than reducing it. That said, using Rails demonstrates familiarity with a complex, production-grade framework.

### Haskell — Scotty

Scotty is a lightweight, Sinatra-inspired framework — a natural fit for a scraper with simple routing and no persistence layer. A heavier framework like Yesod or Servant would add significant complexity with no benefit for this use case.

I could have gone lower-level with WAI + Warp directly, but Scotty added just enough structure to make the routing readable while learning the language. The choice mirrors the Rails/Sinatra reasoning: I evaluated the options and picked the one appropriate for the scope.

## First Contact with Haskell

This is my first Haskell project, built with AI assistance. The aim was to understand what I was writing — not just generate code — so I focused on getting the fundamentals right: pure functions, strong typing, and deliberate module separation across `Scraper`, `Filter`, `View`, and `Main`.

I chose HSpec as the test framework to mirror the RSpec style I know from Ruby, which made the testing experience more approachable while learning. I also used QuickCheck for one property-based test — a Haskell-idiomatic technique worth exploring.

One real-world issue: Scotty 0.30 doesn't compile on GHC 9.14.1, so I had to pin to 0.22. It's a small thing, but it's the kind of friction that comes with working in an unfamiliar ecosystem.

## What I'd Do Differently

**Haskell:** Skip Scotty and go directly with WAI + Warp to avoid the version pinning issue and have more explicit control over the stack. I'd also invest more time understanding monads and idiomatic Haskell patterns before building — I touched the surface but there's clearly more depth to explore.

**Ruby:** Use Sinatra instead of Rails. Without a database, the Rails setup is heavier than the problem warrants. Starting from Sinatra would have been cleaner and more honest about the app's actual scope.

## What Both Implementations Share

- Fetches top 30 entries from Hacker News in real time
- Three filter modes: all entries / long titles (>5 words, sorted by comments) / short titles (≤5 words, sorted by points)
- Word count rule: only tokens containing at least one alphanumeric character are counted
- Tailwind CSS, tabular display, filter navigation
- Unit tests
