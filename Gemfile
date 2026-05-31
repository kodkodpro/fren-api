# frozen_string_literal: true

source "https://rubygems.org"

gem "rails", "8.1.3"

gem "bootsnap", "1.24.4", require: false
gem "jwt", "3.2.0"
gem "memery", "1.8.0"
gem "nilify_blanks", "1.4.0"
gem "pg", "1.6.3"
gem "puma", "8.0.1"
gem "rack-attack", "6.8.0"
gem "redis", "5.4.1"
gem "sentry-rails", "6.5.0"
gem "sentry-ruby", "6.5.0"
gem "thruster", "0.1.21", require: false
gem "wannabe_bool", "0.7.1"

# Custom-made
gem "boba", github: "akodkod/boba" # With support for the latest Tapioca
gem "operandi", github: "akodkod/operandi"
gem "sorbet-model-attributes", github: "akodkod/sorbet-model-attributes"
gem "sorbet-model-enum", github: "akodkod/sorbet-model-enum"

gem "sorbet-schema", "0.9.3"
gem "sorbet-static-and-runtime", "0.6.13244"
gem "tapioca", "0.19.1", require: false, group: [:development, :test]

group :development do
  gem "annotaterb", "4.22.0"
  gem "brakeman", "8.0.4", require: false
  gem "bundler-audit", "0.9.3"
  gem "bundle_update_interactive", "0.13.1"
  gem "rubocop", "1.86.2", require: false
  gem "rubocop-capybara", "2.23.0", require: false
  gem "rubocop-factory_bot", "2.28.0", require: false
  gem "rubocop-minitest", "0.39.1", require: false
  gem "rubocop-performance", "1.26.1", require: false
  gem "rubocop-rails", "2.35.2", require: false
  gem "rubocop-sane", github: "akodkod/rubocop-sane", require: false
  gem "rubocop-sorbet", "0.12.0", require: false
  gem "rubocop-thread_safety", "0.7.3", require: false
  gem "ruby-lsp", "0.26.9"
  gem "web-console", "4.3.0"
end

group :development, :test do
  gem "debug", "1.11.1"
  gem "dotenv", "3.2.0"
  gem "factory_bot", "6.6.0"
  gem "faker", "3.8.0"
  gem "minitest", "6.0.6"
  gem "spy", "1.0.5", require: false
  gem "webmock", "3.26.2", require: false
end
