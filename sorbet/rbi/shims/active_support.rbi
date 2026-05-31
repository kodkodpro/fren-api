# typed: true

class ActiveSupport::Deprecation
  sig { params(value: T::Boolean).returns(T::Boolean) }
  def self.silenced=(value); end
end
