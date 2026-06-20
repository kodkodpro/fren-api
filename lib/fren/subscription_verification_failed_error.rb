# typed: true
# frozen_string_literal: true

class Fren::SubscriptionVerificationFailedError < Fren::SubscriptionError
  class << self
    extend T::Sig

    sig { returns(Fren::ErrorCode) }
    def code
      Fren::ErrorCode::SubscriptionVerificationFailed
    end
  end
end
