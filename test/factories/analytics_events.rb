# typed: true
# frozen_string_literal: true

FactoryBot.define do
  factory :analytics_event do
    user
    name { 1 }
    properties { {} }
    tier { Analytics::Tier::Unknown.serialize }
    occurred_at { Time.current }
  end
end
