# typed: true
# frozen_string_literal: true

class Fren::ErrorCode < T::Enum
  enums do
    AuthenticationFailed = new("authentication_failed")
    SubscriptionRequired = new("subscription_required")
    SubscriptionVerificationFailed = new("subscription_verification_failed")
    FreeAIAnalysisExhausted = new("free_ai_analysis_exhausted")
  end
end
