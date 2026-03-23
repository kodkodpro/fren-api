# typed: true
# frozen_string_literal: true

FactoryBot.define do
  factory :feedback do
    user
    email { Faker::Internet.email }
    message { Faker::Lorem.sentence(word_count: 10) }
  end
end
