# typed: true
# frozen_string_literal: true

FactoryBot.define do
  factory :analytics_event do
    user
    name { 0 }
    properties { {} }
    occurred_at { Time.current }
  end
end
