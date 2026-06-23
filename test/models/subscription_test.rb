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
require "test_helper"

class SubscriptionTest < ActiveSupport::TestCase
  # Validations

  test "is valid with required fields" do
    assert_predicate build(:subscription), :valid?
  end

  test "requires transaction_id" do
    sub = build(:subscription, transaction_id: nil)

    assert_not sub.valid?
    assert_includes sub.errors[:transaction_id], "can't be blank"
  end

  test "enforces transaction_id uniqueness" do
    create(:subscription, transaction_id: "tx-1")
    duplicate = build(:subscription, transaction_id: "tx-1")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:transaction_id], "has already been taken"
  end

  test "requires refreshed_at" do
    sub = build(:subscription, refreshed_at: nil)

    assert_not sub.valid?
    assert_includes sub.errors[:refreshed_at], "can't be blank"
  end

  # Status enum (sorbet_enum bridge)

  test "stores status as the T::Enum's integer" do
    sub = create(:subscription, :in_grace_period)

    assert_equal Subscription::Status::InGracePeriod.serialize, sub.read_attribute_before_type_cast(:status)
  end

  test "reads status back as a T::Enum instance" do
    sub = create(:subscription, :active)

    assert_kind_of Subscription::Status, sub.status
    assert_equal Subscription::Status::Active, sub.status
  end

  test "accepts T::Enum instance on assignment" do
    sub = build(:subscription)
    sub.status = Subscription::Status::Revoked

    assert_equal Subscription::Status::Revoked, sub.status
  end

  test "accepts integer on assignment" do
    sub = build(:subscription)
    sub.status = Subscription::Status::Expired.serialize

    assert_equal Subscription::Status::Expired, sub.status
  end

  test "accepts symbol on assignment" do
    sub = build(:subscription)
    sub.status = :in_billing_retry

    assert_equal Subscription::Status::InBillingRetry, sub.status
  end

  test "generates predicate methods for each status" do
    sub = build(:subscription, :in_grace_period)

    assert_predicate sub, :in_grace_period?
    assert_not_predicate sub, :active?
  end

  test "generates Rails scopes for each status" do
    active = create(:subscription, :active)
    expired = create(:subscription, :expired)

    assert_includes Subscription.active, active
    assert_not_includes Subscription.active, expired
    assert_includes Subscription.expired, expired
  end

  # entitled?

  test "entitled? returns true for Active" do
    assert_predicate build(:subscription, :active), :entitled?
  end

  test "entitled? returns true for InGracePeriod" do
    assert_predicate build(:subscription, :in_grace_period), :entitled?
  end

  test "entitled? returns false for Expired" do
    assert_not_predicate build(:subscription, :expired), :entitled?
  end

  test "entitled? returns false for InBillingRetry" do
    assert_not_predicate build(:subscription, :in_billing_retry), :entitled?
  end

  test "entitled? returns false for Revoked" do
    assert_not_predicate build(:subscription, :revoked), :entitled?
  end
end
