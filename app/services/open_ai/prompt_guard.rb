# typed: true
# frozen_string_literal: true

class OpenAI::PromptGuard < ApplicationService
  extend T::Sig

  TRANSCRIPTION_PATH = "v1/audio/transcriptions"
  CHAT_COMPLETIONS_PATH = "v1/chat/completions"

  PROMPT_FRAGMENT_SETS = T.let(
    [
      [
        "You will be analyzing a voice memo transcript from a user who is tracking their daily experiences.",
        "Your final output should contain only the dayScore and moods tags with your assessments.",
      ],
      [
        "You are helping build a memo tracking application for people with ADHD and similar challenges.",
        "Every category key must be present. Use an empty array for categories with no tags.",
      ],
      [
        "You are helping to process voice memo transcripts for a memo tracking application designed for people with ADHD and similar challenges.",
        "Provide only the cleaned-up transcript without any additional commentary, explanations, or tags.",
      ],
      [
        "You will be writing a supportive, personalized message from Fren, the mascot of a memo tracking app designed for people with ADHD and similar challenges.",
        "Your response should make the user feel heard, supported, and encouraged.",
      ],
      [
        "You are helping to build a memo tracking application for people with ADHD and similar challenges. Your task is to create a short retrieval-friendly summary of a voice memo transcript.",
        "Return only the summary text, nothing else",
      ],
      [
        "You are helping to build a memo tracking application for people with ADHD and similar challenges. Your task is to analyze a voice memo transcript and generate a concise title and representative emoji for it.",
        "Your final output should contain only the title and emoji tags with their respective content.",
      ],
      [
        "You will be acting as \"Fren,\" a friendly mascot for a mental health journaling app.",
        "Each notification will be delivered as a push notification, one per day, starting the day after the memo was recorded",
      ],
      [
        "You are helping to build a memo tracking application for people with ADHD and similar challenges. Your task is to pick a single emoji that visually represents a user-created tag.",
        "Do NOT include any text, words, punctuation, or multiple emojis",
      ],
    ].freeze,
    T::Array[T::Array[String]],
  )

  # Arguments
  arg :path, type: String
  arg :raw_body, type: String
  arg :content_type, type: T.nilable(String), optional: true

  # Steps
  step :allow_transcription_path
  step :reject_unknown_path
  step :reject_invalid_content_type
  step :parse_messages
  step :check_prompt_fragments

  # Outputs
  output :allowed, type: T::Boolean
  output :reason, type: T.nilable(String), optional: true

  private

  sig { returns(T::Array[T.untyped]) }
  attr_accessor :messages

  def allow_transcription_path
    return unless path == TRANSCRIPTION_PATH

    allow_request
  end

  def reject_unknown_path
    deny_request("unknown_path") unless path == CHAT_COMPLETIONS_PATH
  end

  def reject_invalid_content_type
    content_type = self.content_type
    return unless content_type.present? && content_type.downcase.exclude?("json")

    deny_request("invalid_json")
  end

  def parse_messages
    parsed_messages = parsed_messages_from(raw_body)
    return deny_request("invalid_json") unless parsed_messages

    self.messages = parsed_messages
  end

  def check_prompt_fragments
    prompt_text = messages.filter_map { |message| message_content(message) }.join("\n")

    has_valid_fragments = PROMPT_FRAGMENT_SETS.any? do |fragments|
      fragments.all? do |fragment|
        prompt_text.include?(fragment)
      end
    end

    return allow_request if has_valid_fragments

    deny_request("missing_prompt_fragment")
  end

  def allow_request
    self.allowed = true
    self.reason = nil

    stop!
  end

  def deny_request(reason)
    self.allowed = false
    self.reason = reason

    stop!
  end

  sig { params(raw_body: String).returns(T.nilable(T::Array[T.untyped])) }
  def parsed_messages_from(raw_body)
    return nil if raw_body.blank?

    json = JSON.parse(raw_body)
    return nil unless json.is_a?(Hash)

    parsed_messages = json["messages"]
    return nil unless parsed_messages.is_a?(Array)

    parsed_messages
  rescue JSON::ParserError
    nil
  end

  sig { params(message: T.untyped).returns(T.nilable(String)) }
  def message_content(message)
    return nil unless message.is_a?(Hash)

    strings = collect_strings(message["content"])
    return nil if strings.empty?

    strings.join("\n")
  end

  sig { params(value: T.untyped).returns(T::Array[String]) }
  def collect_strings(value)
    case value
    when String
      [value]
    when Array
      value.flat_map { |item| collect_strings(item) }
    when Hash
      value.values.flat_map { |item| collect_strings(item) }
    else
      []
    end
  end
end
