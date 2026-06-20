# typed: true
# frozen_string_literal: true

class Fren::Error < StandardError
  extend T::Sig

  delegate :code, to: :class

  class << self
    extend T::Sig

    sig { returns(T.nilable(Fren::ErrorCode)) }
    def code
      nil
    end
  end
end
