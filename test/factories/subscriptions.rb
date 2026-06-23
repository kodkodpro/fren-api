# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: subscriptions
#
#  id             :uuid             not null, primary key
#  data           :jsonb            not null
#  refreshed_at   :datetime         not null
#  status         :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  transaction_id :string           not null
#  user_id        :uuid             not null
#
# Indexes
#
#  index_subscriptions_on_status          (status)
#  index_subscriptions_on_transaction_id  (transaction_id) UNIQUE
#  index_subscriptions_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id) ON DELETE => cascade
#
FactoryBot.define do
  factory :subscription do
    user
    transaction_id { SecureRandom.hex(10) }
    status { Subscription::Status::Active.serialize }
    data { {} }
    refreshed_at { Time.current }

    trait :active do
      status { Subscription::Status::Active.serialize }
    end

    trait :expired do
      status { Subscription::Status::Expired.serialize }
    end

    trait :in_billing_retry do
      status { Subscription::Status::InBillingRetry.serialize }
    end

    trait :in_grace_period do
      status { Subscription::Status::InGracePeriod.serialize }
    end

    trait :revoked do
      status { Subscription::Status::Revoked.serialize }
    end

    trait :stale do
      refreshed_at { 2.hours.ago }
    end
  end
end
