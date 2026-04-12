# typed: true
# frozen_string_literal: true

class Analytics::EventName < T::Enum
  enums do
    AppOpen = new(0)
    AppBackground = new(1)
    MessageSent = new(2)
    MessageReceived = new(3)
    RecordingStarted = new(4)
    RecordingStopped = new(5)
    ConversationCreated = new(6)
    ConversationDeleted = new(7)
    SettingsOpened = new(8)
    SubscriptionViewed = new(9)
    SubscriptionPurchased = new(10)
    OnboardingStarted = new(11)
    OnboardingCompleted = new(12)
    ErrorOccurred = new(13)
  end
end
