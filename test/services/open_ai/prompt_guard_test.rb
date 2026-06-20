# typed: true
# frozen_string_literal: true

require "test_helper"

class OpenAI::PromptGuardTest < ActiveSupport::TestCase
  test "allows transcription requests without json or prompt checks" do
    result = check(
      path: "v1/audio/transcriptions",
      raw_body: "",
      content_type: "multipart/form-data; boundary=abc",
    )

    assert result.allowed
    assert_nil result.reason
  end

  test "denies unknown paths" do
    result = check(path: "v1/models")

    assert_not result.allowed
    assert_equal "unknown_path", result.reason
  end

  test "denies chat completions with non-json content type" do
    result = check(content_type: "text/plain")

    assert_not result.allowed
    assert_equal "invalid_json", result.reason
  end

  test "denies malformed blank and missing message json" do
    [
      "",
      "{",
      JSON.generate([]),
      JSON.generate(model: "gpt-5.4"),
      JSON.generate(messages: "hello"),
    ].each do |raw_body|
      result = check(raw_body:)

      assert_not result.allowed
      assert_equal "invalid_json", result.reason
    end
  end

  test "allows known app prompts" do
    result = check(raw_body: chat_body(valid_prompt_text))

    assert result.allowed
    assert_nil result.reason
  end

  test "allows known app prompts nested in array and hash content" do
    result = check(
      raw_body: JSON.generate(
        model: "gpt-5.4",
        messages: [
          role: "system",
          content: [
            type: "text",
            text: {
              lines: valid_prompt_fragments,
            },
          ],
        ],
      ),
    )

    assert result.allowed
    assert_nil result.reason
  end

  test "denies unknown prompts" do
    result = check(raw_body: chat_body("hi"))

    assert_not result.allowed
    assert_equal "missing_prompt_fragment", result.reason
  end

  test "allowed returns a boolean" do
    result = OpenAI::PromptGuard.run!(
      path: "v1/chat/completions",
      raw_body: chat_body(valid_prompt_text),
      content_type: "application/json",
    )

    assert result.allowed
  end

  private

  def check(path: "v1/chat/completions", raw_body: chat_body("hi"), content_type: "application/json")
    OpenAI::PromptGuard.run!(path:, raw_body:, content_type:)
  end

  def chat_body(content)
    JSON.generate(
      model: "gpt-5.4",
      messages: [
        role: "system",
        content:,
      ],
    )
  end

  def valid_prompt_text
    valid_prompt_fragments.join("\n")
  end

  def valid_prompt_fragments
    [
      "You are helping to build a memo tracking application for people with ADHD and similar challenges. Your task is to analyze a voice memo transcript and generate a concise title and representative emoji for it.",
      "Here is the memo text to analyze:",
      "Your final output should contain only the title and emoji tags with their respective content.",
    ]
  end
end
