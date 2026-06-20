# typed: true
# frozen_string_literal: true

class Fren::FreeMemoQuotaExhaustedError < Fren::SubscriptionError
  class << self
    extend T::Sig

    sig { returns(Fren::ErrorCode) }
    def code
      Fren::ErrorCode::FreeMemoQuotaExhausted
    end
  end
end
