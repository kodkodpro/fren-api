# typed: true
# frozen_string_literal: true

class Fren::SubscriptionRequiredError < Fren::SubscriptionError
  class << self
    extend T::Sig

    sig { returns(Fren::ErrorCode) }
    def code
      Fren::ErrorCode::SubscriptionRequired
    end
  end
end
