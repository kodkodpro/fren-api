# typed: true
# frozen_string_literal: true

require "test_helper"

class HealthControllerTest < ActionDispatch::IntegrationTest
  test "index returns success with body" do
    get rails_health_check_url

    assert_response :success
    assert_equal "We're good! Don't worry 😉", response.body
  end
end
