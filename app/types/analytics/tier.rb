# typed: true
# frozen_string_literal: true

class Analytics::Tier < T::Enum
  enums do
    Unknown = new(0)
    Free = new(1)
    Trial = new(2)
    Subscribed = new(3)
  end

  def self.deserialize_payload(value)
    return Unknown if value.nil?

    case value
    when "unknown" then Unknown
    when "free" then Free
    when "trial" then Trial
    when "subscribed" then Subscribed
    else raise KeyError, "invalid tier: #{value.inspect}"
    end
  end
end
