# CLAUDE.md

## Commands

```bash
bin/setup                # Install deps, prepare DB, start dev server
bin/dev                  # Start development server
bin/rails test           # Run all tests
bin/rails test test/controllers/proxy_controller_test.rb        # Run single test file
bin/rails test test/controllers/proxy_controller_test.rb:7      # Run single test by line
bin/ci                   # Full CI pipeline (rubocop, bundler-audit, brakeman, tests, seeds)
bin/rubocop              # Lint
bin/rubocop -a           # Lint with auto-correct
bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error  # Security static analysis
bin/bundler-audit        # Dependency vulnerability audit
bin/tapioca              # Regenerate Sorbet type stubs
bin/rails db:migrate     # Run migrations
bin/rails db:prepare     # Create + migrate + seed
bin/rails db:reset       # Drop + create + migrate + seed
```

## Architecture

Rails 8.1 API-only app (Ruby 4.0.1, PostgreSQL) that serves as a reverse proxy for the OpenAI API, built for the Momo iOS app. Future scope: authorization, caching, rate limiting, subscription verification, dynamic app config.

### Key routes

- `match "proxy/openai/*path"` — reverse-proxies to OpenAI API with injected auth headers
- `get "up"` — health check
- `root` — home

### Key libraries

- **rails-reverse-proxy** — proxies requests in `ProxyController`
- **sorbet** (`typed: true` minimum) — static + runtime type checking
- **sorbet-schema** — typed structs (used for `EnvConfig` in `lib/env.rb`)
- **memery** — memoization (included in `ApplicationController`)
- **operandi** — service object pattern (github: akodkod/operandi)
- **rubocop-sane** — custom RuboCop rules (github: akodkod/rubocop-sane)
- **spy** — test spies/mocks; custom assertions in `test/support/spy.rb`

### Environment config

Typed env vars live in `lib/env.rb` as a `T::Struct` called `EnvConfig`. Access via the `Env` constant (e.g., `Env.openai_api_key`). Add new env vars there as typed properties.

## Testing

Support files in `test/support/` are auto-loaded. Custom assertions available:

- `assert_spy_called(spy)` — asserts the spy was called at least once
- `assert_spy_not_called(spy)` — asserts the spy was never called

## Code style

### File headers

Every `.rb` file starts with two lines:

```ruby
# typed: true
# frozen_string_literal: true
```

Use `# typed: strict` for initializers and config files.

### Conventions

- **Double quotes** for all strings
- **Trailing commas** in multiline arrays/hashes (`consistent_comma`); `diff_comma` for method args
- **Compact class style** — `class Momo::Application < Rails::Application` not nested modules
- **Lambda literal** — `->` not `lambda`
- **Hash shorthand** — `{ key: }` when variable matches symbol name
- **No line length limit**, no method/class/block length limits

### Multiline formatting

First argument/parameter on its own line when breaking across lines. `AllowMultilineFinalElement: true`.
