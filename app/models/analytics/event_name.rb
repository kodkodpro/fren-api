# typed: true
# frozen_string_literal: true

class Analytics::EventName < T::Enum
  enums do
    AppOpened = new(1)
    AppClosed = new(2)
    OnboardingStarted = new(3)
    OnboardingCompleted = new(4)
    OnboardingStepViewed = new(5)
    OnboardingBackTapped = new(25)
    RecordingStarted = new(6)
    RecordingStopped = new(7)
    RecordingPaused = new(8)
    RecordingResumed = new(9)
    MemoCreated = new(10)
    MemoUpdated = new(11)
    MemoDeleted = new(12)
    MemoViewed = new(13)
    MemoRecordingPlayed = new(14)
    TagCreated = new(15)
    TagUpdated = new(16)
    TagDeleted = new(17)
    ScreenViewed = new(18)
    AIRequestCompleted = new(19)
    AITranscribeCompleted = new(28)
    NotificationsGenerated = new(20)
    NotificationOpened = new(21)
    ButtonTapped = new(22)
    MicPermissionResult = new(23)
    NotificationsPermissionResult = new(24)
    OnboardingLanguageSelected = new(26)
    UserLanguageChanged = new(27)
  end

  def properties_schema
    case self
    when OnboardingStepViewed, OnboardingBackTapped then Analytics::Properties::OnboardingStepViewed
    when RecordingStopped then Analytics::Properties::RecordingStopped
    when ScreenViewed then Analytics::Properties::ScreenViewed
    when AIRequestCompleted then Analytics::Properties::AIRequestCompleted
    when NotificationsGenerated then Analytics::Properties::NotificationsGenerated
    when ButtonTapped then Analytics::Properties::ButtonTapped
    when MicPermissionResult, NotificationsPermissionResult then Analytics::Properties::PermissionResult
    when OnboardingLanguageSelected, UserLanguageChanged then Analytics::Properties::LanguageSelected
    else Analytics::Properties::Empty
    end
  end
end
