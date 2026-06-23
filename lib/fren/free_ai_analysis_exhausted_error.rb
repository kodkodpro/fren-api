# typed: true
# frozen_string_literal: true

class Fren::FreeAIAnalysisExhaustedError < Fren::SubscriptionError
  class << self
    extend T::Sig

    sig { returns(Fren::ErrorCode) }
    def code
      Fren::ErrorCode::FreeAIAnalysisExhausted
    end
  end
end
