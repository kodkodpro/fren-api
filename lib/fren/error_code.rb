# typed: true
# frozen_string_literal: true

class Fren::ErrorCode < T::Enum
  enums do
    AuthenticationFailed = new("authentication_failed")
    SubscriptionRequired = new("subscription_required")
    SubscriptionVerificationFailed = new("subscription_verification_failed")
    FreeMemoQuotaExhausted = new("free_memo_quota_exhausted")
  end
end
