# typed: true
# frozen_string_literal: true

require "test_helper"

class HealthControllerTest < ActionDispatch::IntegrationTest
  test "index returns success with body" do
    get rails_health_check_url

    assert_response :success
    assert_equal "We're good! Don't worry 😉", response.body
  end

  test "trigger_sentry_error raises RuntimeError" do
    capture_exception_spy = Spy.on(Sentry, :capture_exception)

    assert_raises(RuntimeError) do
      get trigger_sentry_error_url
    end

    assert_spy_called capture_exception_spy, "Sentry.capture_exception was not called"
  end

  test "trigger_sentry_message returns success with confirmation" do
    capture_message_spy = Spy.on(Sentry, :capture_message)

    get trigger_sentry_message_url

    assert_response :success
    assert_includes response.body, "Sentry message sent!"

    assert_spy_called capture_message_spy, "Sentry.capture_message was not called"
  end
end
