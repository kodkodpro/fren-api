# typed: true
# frozen_string_literal: true

require "test_helper"

class RemoteConfigTest < ActiveSupport::TestCase
  setup do
    REDIS.del(RemoteConfig::REDIS_KEY)
  end

  test "block sets a block with message only" do
    RemoteConfig.block(:block_app, message: "App is blocked")

    config = RemoteConfig.load

    assert_equal "App is blocked", T.must(config.block_app).message
    assert_nil T.must(config.block_app).button
  end

  test "block sets a block with message and button" do
    RemoteConfig.block(:block_app, message: "Update required", button: { text: "Update", url: "https://example.com" })

    config = RemoteConfig.load

    assert_equal "Update required", T.must(config.block_app).message
    assert_equal "Update", T.must(T.must(config.block_app).button).text
    assert_equal "https://example.com", T.must(T.must(config.block_app).button).url
  end

  test "block accepts a BlockConfig struct" do
    block_config = RemoteConfig::Struct::BlockConfig.new(message: "Blocked")
    RemoteConfig.block(:block_app, block_config)

    assert_equal "Blocked", T.must(RemoteConfig.load.block_app).message
  end

  test "block overwrites an existing block" do
    RemoteConfig.block(:block_app, message: "Old message")
    RemoteConfig.block(:block_app, message: "New message")

    assert_equal "New message", T.must(RemoteConfig.load.block_app).message
  end

  test "block preserves other blocks" do
    RemoteConfig.block(:block_app, message: "App blocked")
    RemoteConfig.block(:block_recording, message: "Recording blocked")

    config = RemoteConfig.load

    assert_equal "App blocked", T.must(config.block_app).message
    assert_equal "Recording blocked", T.must(config.block_recording).message
  end

  test "block raises ArgumentError for unknown block" do
    assert_raises(ArgumentError) { RemoteConfig.block(:invalid_block, message: "test") }
  end

  test "unblock removes a block" do
    RemoteConfig.block(:block_app, message: "Blocked")
    RemoteConfig.unblock(:block_app)

    assert_nil RemoteConfig.load.block_app
  end

  test "unblock preserves other blocks" do
    RemoteConfig.block(:block_app, message: "App blocked")
    RemoteConfig.block(:block_recording, message: "Recording blocked")
    RemoteConfig.unblock(:block_app)

    config = RemoteConfig.load

    assert_nil config.block_app
    assert_equal "Recording blocked", T.must(config.block_recording).message
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
    RemoteConfig.block(:block_app, message: "Update required", button: { text: "Update", url: "https://example.com/update" })

    result = RemoteConfig.to_h

    assert_equal "Update required", result.dig(:block_app, :message)
    assert_equal "Update", result.dig(:block_app, :button, :text)
    assert_equal "https://example.com/update", result.dig(:block_app, :button, :url)
    assert_nil result[:block_recording]
  end

  test "to_h returns empty hash when nothing is set" do
    result = RemoteConfig.to_h

    assert_nil result[:block_app]
    assert_nil result[:block_recording]
  end
end
