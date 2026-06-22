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

  test "creates batch through battle log route" do
    params = {
      events: [
        name: 1, occurred_at: Time.current.iso8601, properties: {}, tier: "free",
      ],
    }

    assert_difference "AnalyticsEvent.count", 1 do
      post battle_log_url,
           params:,
           headers: auth_headers,
           as: :json
    end

    assert_response :created
  end

  test "saves unknown event names and inserts valid ones" do
    spy = Spy.on(Sentry, :capture_message)

    params = {
      events: [
        { name: 1, occurred_at: Time.current.iso8601, properties: {} },
        { name: 999, occurred_at: Time.current.iso8601, properties: {} },
      ],
    }

    assert_difference "AnalyticsEvent.count", 2 do
      post analytics_url,
           params:,
           headers: auth_headers,
           as: :json
    end

    assert_response :created
    assert AnalyticsEvent.exists?(name: 999)
    assert_spy_called(spy)
  end

  test "saves events with invalid properties" do
    spy = Spy.on(Sentry, :capture_message)

    params = {
      events: [
        name: 7, occurred_at: Time.current.iso8601, properties: {},
      ],
    }

    assert_difference "AnalyticsEvent.count", 1 do
      post analytics_url,
           params:,
           headers: auth_headers,
           as: :json
    end

    assert_response :created
    assert_equal({}, AnalyticsEvent.last!.properties)
    assert_spy_called(spy)
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

  test "stores tier as integer enum" do
    params = {
      events: [
        name: 1, occurred_at: Time.current.iso8601, properties: {}, tier: "subscribed",
      ],
    }

    post analytics_url,
         params:,
         headers: auth_headers,
         as: :json

    event = AnalyticsEvent.last!

    assert_equal Analytics::Tier::Subscribed, event.tier
    assert_equal Analytics::Tier::Subscribed.serialize, event.read_attribute_before_type_cast(:tier)
  end

  test "defaults missing tier to unknown" do
    params = {
      events: [
        name: 1, occurred_at: Time.current.iso8601, properties: {},
      ],
    }

    post analytics_url,
         params:,
         headers: auth_headers,
         as: :json

    assert_equal Analytics::Tier::Unknown, AnalyticsEvent.last!.tier
  end

  test "saves invalid tier as unknown and inserts valid events" do
    spy = Spy.on(Sentry, :capture_message)

    params = {
      events: [
        { name: 1, occurred_at: Time.current.iso8601, properties: {}, tier: "free" },
        { name: 2, occurred_at: Time.current.iso8601, properties: {}, tier: "enterprise" },
      ],
    }

    assert_difference "AnalyticsEvent.count", 2 do
      post analytics_url,
           params:,
           headers: auth_headers,
           as: :json
    end

    assert_response :created
    assert_equal Analytics::Tier::Free, AnalyticsEvent.find_by!(name: 1).tier
    assert_equal Analytics::Tier::Unknown, AnalyticsEvent.find_by!(name: 2).tier
    assert_spy_called(spy)
  end

  test "saves invalid occurred_at with current time" do
    spy = Spy.on(Sentry, :capture_message)
    occurred_at = Time.zone.local(2026, 6, 22, 12, 0, 0)

    travel_to occurred_at do
      params = {
        events: [
          name: 1, occurred_at: "not-a-date", properties: {}, tier: "free",
        ],
      }

      assert_difference "AnalyticsEvent.count", 1 do
        post analytics_url,
             params:,
             headers: auth_headers,
             as: :json
      end
    end

    assert_response :created
    assert_equal occurred_at, AnalyticsEvent.last!.occurred_at
    assert_spy_called(spy)
  end

  test "accepts quick record widget event" do
    params = {
      events: [
        name: 29, occurred_at: Time.current.iso8601, properties: {}, tier: "free",
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

  test "accepts app review events" do
    params = {
      events: [
        { name: 30, occurred_at: Time.current.iso8601, properties: { trigger: "settings" }, tier: "free" },
        { name: 34, occurred_at: Time.current.iso8601, properties: { trigger: "memo", reason: "tooSoon" }, tier: "trial" },
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

  test "reports invalid events to Sentry" do
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
    assert_equal "X-User-Id header is required", response_json.dig("error", "message")
    assert_equal "authentication_failed", response_json.dig("error", "code")
  end
end
