# typed: true
# frozen_string_literal: true

require "test_helper"

class RemoteConfigTest < ActiveSupport::TestCase
  setup do
    RemoteConfig.reset!
  end

  test "block sets a block with title and text only" do
    RemoteConfig.block(:block_app, title: "Blocked", text: "App is blocked")

    config = RemoteConfig.load

    assert_equal "Blocked", T.must(config.block_app).title
    assert_equal "App is blocked", T.must(config.block_app).text
    assert_nil T.must(config.block_app).emoji
    assert_nil T.must(config.block_app).button
  end

  test "block sets a block with emoji" do
    RemoteConfig.block(:block_app, title: "Blocked", text: "App is blocked", emoji: "🚫")

    config = RemoteConfig.load

    assert_equal "🚫", T.must(config.block_app).emoji
  end

  test "block sets a block with button" do
    RemoteConfig.block(:block_app, title: "Update Required", text: "Please update", button: { text: "Update", url: "https://example.com" })

    config = RemoteConfig.load

    assert_equal "Update Required", T.must(config.block_app).title
    assert_equal "Please update", T.must(config.block_app).text
    assert_equal "Update", T.must(T.must(config.block_app).button).text
    assert_equal "https://example.com", T.must(T.must(config.block_app).button).url
  end

  test "block accepts a BlockConfig struct" do
    block_config = RemoteConfig::Struct::BlockConfig.new(title: "Blocked", text: "App is blocked")
    RemoteConfig.block(:block_app, block_config)

    assert_equal "Blocked", T.must(RemoteConfig.load.block_app).title
  end

  test "block overwrites an existing block" do
    RemoteConfig.block(:block_app, title: "Old", text: "Old message")
    RemoteConfig.block(:block_app, title: "New", text: "New message")

    assert_equal "New", T.must(RemoteConfig.load.block_app).title
    assert_equal "New message", T.must(RemoteConfig.load.block_app).text
  end

  test "block preserves other blocks" do
    RemoteConfig.block(:block_app, title: "App", text: "App blocked")
    RemoteConfig.block(:block_recording, title: "Recording", text: "Recording blocked")

    config = RemoteConfig.load

    assert_equal "App", T.must(config.block_app).title
    assert_equal "Recording", T.must(config.block_recording).title
  end

  test "block raises ArgumentError for unknown block" do
    assert_raises(ArgumentError) { RemoteConfig.block(:invalid_block, title: "Test", text: "test") }
  end

  test "unblock removes a block" do
    RemoteConfig.block(:block_app, title: "Blocked", text: "App is blocked")
    RemoteConfig.unblock(:block_app)

    assert_nil RemoteConfig.load.block_app
  end

  test "unblock preserves other blocks" do
    RemoteConfig.block(:block_app, title: "App", text: "App blocked")
    RemoteConfig.block(:block_recording, title: "Recording", text: "Recording blocked")
    RemoteConfig.unblock(:block_app)

    config = RemoteConfig.load

    assert_nil config.block_app
    assert_equal "Recording", T.must(config.block_recording).title
  end

  test "unblock is a no-op when block is not set" do
    RemoteConfig.unblock(:block_app)

    assert_nil RemoteConfig.load.block_app
  end

  test "unblock raises ArgumentError for unknown block" do
    assert_raises(ArgumentError) { RemoteConfig.unblock(:invalid_block) }
  end

  test "load returns struct with nil blocks when nothing is set" do
    config = RemoteConfig.load

    assert_instance_of RemoteConfig::Struct, config
    assert_nil config.block_app
    assert_nil config.block_recording
  end

  test "to_h returns nested hash with symbol keys" do
    RemoteConfig.block(:block_app, title: "Update Required", text: "Please update", button: { text: "Update", url: "https://example.com/update" })

    result = RemoteConfig.to_h

    assert_equal "Update Required", result.dig(:block_app, :title)
    assert_equal "Please update", result.dig(:block_app, :text)
    assert_equal "Update", result.dig(:block_app, :button, :text)
    assert_equal "https://example.com/update", result.dig(:block_app, :button, :url)
    assert_nil result[:block_recording]
  end

  test "to_h returns empty hash when nothing is set" do
    result = RemoteConfig.to_h

    assert_nil result[:block_app]
    assert_nil result[:block_recording]
  end

  test "set stores a TranscriptionProvider enum value" do
    RemoteConfig.set(:transcription_provider, RemoteConfig::TranscriptionProvider::ElevenLabs)

    assert_equal RemoteConfig::TranscriptionProvider::ElevenLabs, RemoteConfig.load.transcription_provider
  end

  test "set accepts a serialized string value" do
    RemoteConfig.set(:transcription_provider, "openai")

    assert_equal RemoteConfig::TranscriptionProvider::OpenAI, RemoteConfig.load.transcription_provider
  end

  test "set overwrites an existing value" do
    RemoteConfig.set(:transcription_provider, RemoteConfig::TranscriptionProvider::OpenAI)
    RemoteConfig.set(:transcription_provider, RemoteConfig::TranscriptionProvider::ElevenLabs)

    assert_equal RemoteConfig::TranscriptionProvider::ElevenLabs, RemoteConfig.load.transcription_provider
  end

  test "set preserves existing blocks" do
    RemoteConfig.block(:block_app, title: "App", text: "App blocked")
    RemoteConfig.set(:transcription_provider, RemoteConfig::TranscriptionProvider::OpenAI)

    config = RemoteConfig.load

    assert_equal "App", T.must(config.block_app).title
    assert_equal RemoteConfig::TranscriptionProvider::OpenAI, config.transcription_provider
  end

  test "set raises ArgumentError for unknown setting" do
    assert_raises(ArgumentError) { RemoteConfig.set(:unknown_setting, "value") }
  end

  test "unset clears a setting" do
    RemoteConfig.set(:transcription_provider, RemoteConfig::TranscriptionProvider::OpenAI)
    RemoteConfig.unset(:transcription_provider)

    assert_nil RemoteConfig.load.transcription_provider
  end

  test "unset is a no-op when setting is not set" do
    RemoteConfig.unset(:transcription_provider)

    assert_nil RemoteConfig.load.transcription_provider
  end

  test "unset preserves existing blocks" do
    RemoteConfig.block(:block_app, title: "App", text: "App blocked")
    RemoteConfig.set(:transcription_provider, RemoteConfig::TranscriptionProvider::OpenAI)
    RemoteConfig.unset(:transcription_provider)

    config = RemoteConfig.load

    assert_equal "App", T.must(config.block_app).title
    assert_nil config.transcription_provider
  end

  test "unset raises ArgumentError for unknown setting" do
    assert_raises(ArgumentError) { RemoteConfig.unset(:unknown_setting) }
  end

  test "load returns nil transcription_provider by default" do
    assert_nil RemoteConfig.load.transcription_provider
  end

  test "to_h returns the serialized string for transcription_provider" do
    RemoteConfig.set(:transcription_provider, RemoteConfig::TranscriptionProvider::ElevenLabs)

    assert_equal "elevenlabs", RemoteConfig.to_h[:transcription_provider]
  end
end
