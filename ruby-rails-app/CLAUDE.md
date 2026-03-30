# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Stack

- Ruby 4.0.2, Rails 8.1.2
- SQLite via Active Record
- Solid Cache / Solid Queue / Solid Cable (database-backed adapters)
- Propshaft (asset pipeline), Importmap, Tailwind CSS
- Hotwire (Turbo + Stimulus)
- RSpec for tests, RuboCop (omakase style) for linting
- Kamal for deployment

## Commands

```bash
bin/dev          # Start development server (Puma + Tailwind watcher)
bin/setup        # Install deps, prepare DB
bin/rails db:migrate
bin/rails db:seed

# Testing
bundle exec rspec              # Run all specs
bundle exec rspec spec/path/to/file_spec.rb  # Single file
bundle exec rspec spec/path/to/file_spec.rb:42  # Single example

# Linting / Security
bin/rubocop                    # Ruby style
bin/brakeman --quiet --no-pager  # Security scan
bin/bundler-audit              # Gem vulnerability audit
bin/importmap audit            # JS vulnerability audit

# Full CI suite
bin/ci
```

## Architecture

Fresh Rails 8 app — no domain models or controllers exist yet beyond the default skeleton. Routes are empty except the health check at `/up`. The app is structured as a standard Rails MVC application; all application logic will live under `app/`.

Background jobs use Solid Queue (configured in `config/queue.yml`). Caching uses Solid Cache (`config/cache.yml`). Action Cable uses Solid Cable (`config/cable.yml`). All three are database-backed and require no external services.
