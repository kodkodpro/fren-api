# typed: true
# frozen_string_literal: true

require "test_helper"

class RemoteConfigControllerTest < ActionDispatch::IntegrationTest
  setup do
    REDIS.del(RemoteConfig::REDIS_KEY)
  end

  test "returns empty config when nothing is set" do
    get remote_config_url

    assert_response :success
    assert_nil response_json["block_app"]
    assert_nil response_json["block_recording"]
  end

  test "returns config with nested button" do
    RemoteConfig.block(:block_app, message: "App is blocked", button: { text: "Update", url: "https://example.com" })

    get remote_config_url

    assert_response :success
    assert_equal "App is blocked", response_json.dig("block_app", "message")
    assert_equal "Update", response_json.dig("block_app", "button", "text")
    assert_equal "https://example.com", response_json.dig("block_app", "button", "url")
    assert_nil response_json["block_recording"]
  end

  test "does not require authentication" do
    get remote_config_url

    assert_response :success
  end
end
