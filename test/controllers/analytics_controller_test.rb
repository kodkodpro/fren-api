# typed: true
# frozen_string_literal: true

require "test_helper"

class AnalyticsControllerTest < ActionDispatch::IntegrationTest
  test "creates batch of valid events" do
    params = {
      events: [
        { name: 1, occurred_at: Time.current.iso8601, properties: {} },
        { name: 21, occurred_at: Time.current.iso8601, properties: {} },
      ],
    }

    assert_difference "AnalyticsEvent.count", 2 do
      post analytics_url,
           params:,
           headers: auth_headers,
           as: :json
    end

    assert_response :created
  end

  test "skips invalid events and inserts valid ones" do
    params = {
      events: [
        { name: 1, occurred_at: Time.current.iso8601, properties: {} },
        { name: 999, occurred_at: Time.current.iso8601, properties: {} },
      ],
    }

    assert_difference "AnalyticsEvent.count", 1 do
      post analytics_url,
           params:,
           headers: auth_headers,
           as: :json
    end

    assert_response :created
  end

  test "validates required properties" do
    params = {
      events: [
        name: 7, occurred_at: Time.current.iso8601, properties: {},
      ],
    }

    assert_no_difference "AnalyticsEvent.count" do
      post analytics_url,
           params:,
           headers: auth_headers,
           as: :json
    end

    assert_response :created
  end

  test "handles empty events array" do
    params = { events: [] }

    assert_no_difference "AnalyticsEvent.count" do
      post analytics_url,
           params:,
           headers: auth_headers,
           as: :json
    end

    assert_response :created
  end

  test "stores properties as jsonb" do
    props = { name: "analyze_memo", model: "gpt-4o", inputTokens: 100, outputTokens: 50 }
    params = {
      events: [
        name: 19, occurred_at: Time.current.iso8601, properties: props,
      ],
    }

    post analytics_url,
         params:,
         headers: auth_headers,
         as: :json

    event = AnalyticsEvent.last!

    assert_equal "analyze_memo", event.properties["name"]
    assert_equal 100, event.properties["input_tokens"]
  end

  test "reports failed events to Sentry" do
    spy = Spy.on(Sentry, :capture_message)

    params = {
      events: [
        name: 999, occurred_at: Time.current.iso8601, properties: {},
      ],
    }

    post analytics_url,
         params:,
         headers: auth_headers,
         as: :json

    assert_response :created
    assert_spy_called(spy)
  end

  test "does not report to Sentry when all events are valid" do
    spy = Spy.on(Sentry, :capture_message)

    params = {
      events: [
        name: 1, occurred_at: Time.current.iso8601, properties: {},
      ],
    }

    post analytics_url,
         params:,
         headers: auth_headers,
         as: :json

    assert_response :created
    assert_spy_not_called(spy)
  end

  test "requires authentication" do
    post analytics_url,
         params: { events: [] },
         as: :json

    assert_response :unauthorized
    assert_equal "X-User-Id header is required", response_json["error"]
  end
end
