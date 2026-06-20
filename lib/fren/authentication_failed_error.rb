# typed: true
# frozen_string_literal: true

class Fren::AuthenticationFailedError < Fren::AuthError
  class << self
    extend T::Sig

    sig { returns(Fren::ErrorCode) }
    def code
      Fren::ErrorCode::AuthenticationFailed
    end
  end
end
