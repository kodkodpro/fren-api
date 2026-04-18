# typed: true
# frozen_string_literal: true

require "test_helper"

class RemoteConfigControllerTest < ActionDispatch::IntegrationTest
  setup do
    RemoteConfig.reset!
  end

  test "returns empty config when nothing is set" do
    get remote_config_url

    assert_response :success
    assert_nil response_json["block_app"]
    assert_nil response_json["block_recording"]
  end

  test "returns config with nested button" do
    RemoteConfig.block(:block_app, title: "Blocked", text: "App is blocked", button: { text: "Update", url: "https://example.com" })

    get remote_config_url

    assert_response :success
    assert_equal "Blocked", response_json.dig("block_app", "title")
    assert_equal "App is blocked", response_json.dig("block_app", "text")
    assert_equal "Update", response_json.dig("block_app", "button", "text")
    assert_equal "https://example.com", response_json.dig("block_app", "button", "url")
    assert_nil response_json["block_recording"]
  end

  test "does not require authentication" do
    get remote_config_url

    assert_response :success
  end

  test "returns transcription_provider as a serialized string" do
    RemoteConfig.set(:transcription_provider, RemoteConfig::TranscriptionProvider::ElevenLabs)

    get remote_config_url

    assert_response :success
    assert_equal "elevenlabs", response_json["transcription_provider"]
  end

  test "returns nil transcription_provider when unset" do
    get remote_config_url

    assert_response :success
    assert_nil response_json["transcription_provider"]
  end
end
