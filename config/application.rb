# typed: true
# frozen_string_literal: true

require_relative "boot"

require "rails"

require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"

# require "active_job/railtie"
# require "active_storage/engine"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
# require "action_cable/engine"

require "rails/test_unit/railtie"

require_relative "initializers/0_sorbet"
require_relative "../lib/env"
require_relative "../lib/fren"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

class Fren::Application < Rails::Application
  # Initialize configuration defaults
  config.load_defaults 8.1

  # Enable API only mode
  config.api_only = true

  # Ignore autoloading for manually required library support
  config.autoload_lib(ignore: ["tasks", "core_ext", "sorbet"])

  # Set default log level to info
  config.log_level = :info

  # Configuration for the application, engines, and railties goes here.
  #
  # These settings can be overridden in specific environments using the files
  # in config/environments, which are processed later.
  #
  # config.time_zone = "Central Time (US & Canada)"
  # config.eager_load_paths << Rails.root.join("extras")
end
