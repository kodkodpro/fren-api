# typed: true
# frozen_string_literal: true

module Analytics::Properties
  class AppOpen < T::Struct
    const :source, T.nilable(String), default: nil
  end

  class MessageSent < T::Struct
    const :conversation_id, String
    const :message_length, Integer
    const :has_attachment, T.nilable(T::Boolean), default: false
  end

  class MessageReceived < T::Struct
    const :conversation_id, String
    const :response_time_ms, T.nilable(Integer), default: nil
  end

  class RecordingStarted < T::Struct
    const :conversation_id, String
  end

  class RecordingStopped < T::Struct
    const :conversation_id, String
    const :duration_ms, Integer
  end

  class ConversationCreated < T::Struct
    const :conversation_id, String
  end

  class ConversationDeleted < T::Struct
    const :conversation_id, String
  end

  class SubscriptionPurchased < T::Struct
    const :plan, String
    const :price_cents, Integer
  end

  class ErrorOccurred < T::Struct
    const :error_type, String
    const :error_message, T.nilable(String), default: nil
  end

  class Empty < T::Struct; end

  SCHEMAS = T.let(
    {
      Analytics::EventName::AppOpen => AppOpen,
      Analytics::EventName::AppBackground => Empty,
      Analytics::EventName::MessageSent => MessageSent,
      Analytics::EventName::MessageReceived => MessageReceived,
      Analytics::EventName::RecordingStarted => RecordingStarted,
      Analytics::EventName::RecordingStopped => RecordingStopped,
      Analytics::EventName::ConversationCreated => ConversationCreated,
      Analytics::EventName::ConversationDeleted => ConversationDeleted,
      Analytics::EventName::SettingsOpened => Empty,
      Analytics::EventName::SubscriptionViewed => Empty,
      Analytics::EventName::SubscriptionPurchased => SubscriptionPurchased,
      Analytics::EventName::OnboardingStarted => Empty,
      Analytics::EventName::OnboardingCompleted => Empty,
      Analytics::EventName::ErrorOccurred => ErrorOccurred,
    }.freeze,
    T::Hash[Analytics::EventName, T.class_of(T::Struct)],
  )
end
