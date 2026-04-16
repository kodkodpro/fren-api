# typed: true
# frozen_string_literal: true

module Analytics::Properties
  class Empty < T::Struct; end

  class OnboardingStepViewed < T::Struct
    const :step, String
  end

  class RecordingStopped < T::Struct
    const :duration_ms, Integer
  end

  class ScreenViewed < T::Struct
    const :screen, String
  end

  class AIRequestCompleted < T::Struct
    const :name, String
    const :model, String
    const :input_tokens, Integer
    const :output_tokens, Integer
  end

  class NotificationsGenerated < T::Struct
    const :count, Integer
  end

  class ButtonTapped < T::Struct
    const :name, String
  end

  class PermissionResult < T::Struct
    const :granted, T::Boolean
  end

  class LanguageSelected < T::Struct
    const :language, String
  end
end
