# typed: true
# frozen_string_literal: true

require "test_helper"

class AnalyticsControllerTest < ActionDispatch::IntegrationTest
  test "creates batch of valid events" do
    params = {
      events: [
        { name: 0, occurred_at: Time.current.iso8601, properties: { source: "push_notification" } },
        { name: 8, occurred_at: Time.current.iso8601, properties: {} },
      ],
    }

    assert_difference "AnalyticsEvent.count", 2 do
      post analytics_url,
           params:,
           headers: auth_headers,
           as: :json
    end

    assert_response :created
    assert_equal 2, response_json["inserted"]
    assert_empty response_json["errors"]
  end

  test "skips invalid events and inserts valid ones" do
    params = {
      events: [
        { name: 0, occurred_at: Time.current.iso8601, properties: {} },
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
    assert_equal 1, response_json["inserted"]
    assert_equal 1, response_json["errors"].length
    assert_equal "unknown event name", response_json["errors"].first["error"]
  end

  test "validates required properties" do
    params = {
      events: [
        name: 2, occurred_at: Time.current.iso8601, properties: {},
      ],
    }

    assert_no_difference "AnalyticsEvent.count" do
      post analytics_url,
           params:,
           headers: auth_headers,
           as: :json
    end

    assert_response :created
    assert_equal 0, response_json["inserted"]
    assert_equal 1, response_json["errors"].length
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
    assert_equal 0, response_json["inserted"]
  end

  test "stores properties as jsonb" do
    props = { conversation_id: "abc-123", message_length: 42, has_attachment: false }
    params = {
      events: [
        name: 2, occurred_at: Time.current.iso8601, properties: props,
      ],
    }

    post analytics_url,
         params:,
         headers: auth_headers,
         as: :json

    event = AnalyticsEvent.last!

    assert_equal "abc-123", event.properties["conversation_id"]
    assert_equal 42, event.properties["message_length"]
  end

  test "requires authentication" do
    assert_raises(RuntimeError) do
      post analytics_url,
           params: { events: [] },
           as: :json
    end
  end
end
