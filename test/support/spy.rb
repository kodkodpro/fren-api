# typed: true
# frozen_string_literal: true

require "spy/integration"

module Minitest::Assertions
  def assert_spy_called(spy, message = nil)
    assert_predicate spy, :has_been_called?, message
  end

  def assert_spy_not_called(spy, message = nil)
    refute_predicate spy, :has_been_called?, message # rubocop:disable Rails/RefuteMethods
  end
end
