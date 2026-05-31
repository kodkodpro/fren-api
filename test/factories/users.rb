# typed: true
# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    id { SecureRandom.uuid }

    before(:create) do
      create(:paywall) unless Paywall.active_assignable.exists?
    end
  end
end
