# typed: strict
# frozen_string_literal: true

require "wannabe_bool"

module Coercers
  class Boolean < Typed::Coercion::Coercer
    extend T::Generic

    Target = type_member { { fixed: T::Boolean } }

    sig { override.params(type: T::Types::Base).returns(T::Boolean) }
    def self.used_for_type?(type)
      type == T::Utils.coerce(T::Boolean)
    end

    sig { override.params(type: T::Types::Base, value: Typed::Value).returns(Typed::Result[Target, Typed::Coercion::CoercionError]) }
    def coerce(type:, value:)
      return Typed::Failure.new(Typed::Coercion::CoercionError.new("Type must be a T::Boolean.")) unless self.class.used_for_type?(type)
      return Typed::Success.new(value) if type.recursively_valid?(value)

      Typed::Success.new(value.to_b)
    end
  end
end
