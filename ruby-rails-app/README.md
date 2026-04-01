# Hacker News Web Crawler

A Rails 8 app that scrapes the top 30 stories from Hacker News and displays them in a filterable, sortable table. Data is fetched live on each request — no persistence layer.

## Features

- Fetches top 30 entries from Hacker News in real time
- Three display modes (toggled via filter buttons):
  - **All** — all 30 entries in original ranking order
  - **Long Titles** — entries with >5 words in title, sorted by comment count (desc)
  - **Short Titles** — entries with ≤5 words in title, sorted by points (desc)
- Each entry shows: Rank, Title, Points, Comments

## Stack

- Ruby / Rails 8.1.2
- SQLite via Active Record (no custom models — stateless app)
- Nokogiri (HTML parsing)
- Tailwind CSS, Hotwire (Turbo + Stimulus)
- RSpec + Webmock for tests

## Setup & Running

```bash
bin/setup    # Install dependencies, prepare DB
bin/dev      # Start dev server at localhost:3000
```

Visit `http://localhost:3000`.

## Testing

```bash
bundle exec rspec                                    # Run all specs
bundle exec rspec spec/path/to/file_spec.rb          # Single file
bundle exec rspec spec/path/to/file_spec.rb:42       # Single example
```

## Linting & Security

```bash
bin/rubocop                          # Ruby style
bin/brakeman --quiet --no-pager      # Security scan
bin/bundler-audit                    # Gem vulnerability audit
bin/ci                               # Full CI suite
```

## Architecture

| File | Purpose |
|------|---------|
| `app/services/hacker_news_scraper.rb` | Scrapes and parses HN HTML with Nokogiri |
| `app/controllers/crawler_controller.rb` | Applies filter/sort logic, passes data to view |
| `app/views/crawler/index.html.erb` | Tailwind-styled table with filter buttons |
