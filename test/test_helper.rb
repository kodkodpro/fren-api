# typed: true
# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"
require "rails/test_help"

Dir[File.join(File.dirname(__FILE__), "support", "**", "*.rb")].each { |file| require file }

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize workers: :number_of_processors
end
