# typed: true
# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    id { SecureRandom.uuid }
  end
end
