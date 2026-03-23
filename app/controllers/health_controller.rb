# typed: true
# frozen_string_literal: true

class HealthController < PublicController
  def index
    render plain: "We're good! Don't worry 😉"
  end

  def trigger_sentry_error
    raise "This is a test error from the /health/trigger-sentry-error endpoint"
  end

  def trigger_sentry_message
    Sentry.capture_message("This is a test message from the /health/trigger-sentry-message endpoint")
    render plain: "Sentry message sent! Check your Sentry dashboard to see it"
  end
end
