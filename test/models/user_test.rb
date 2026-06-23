# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                         :uuid             not null, primary key
#  free_ai_analyses_available :integer          default(3), not null
#  last_request_at            :datetime
#  created_at                 :datetime         not null
#  paywall_id                 :uuid             not null
#
# Indexes
#
#  index_users_on_paywall_id  (paywall_id)
#
# Foreign Keys
#
#  fk_rails_...  (paywall_id => paywalls.id)
#
require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "assigns paywall on create" do
    paywall = create(:paywall)
    user = User.create!(id: SecureRandom.uuid)

    assert_equal paywall, user.paywall
  end

  test "raises when no assignable paywall exists" do
    create(:paywall, active: false, weight: 1)

    assert_raises(ActiveRecord::RecordNotFound) do
      User.create!(id: SecureRandom.uuid)
    end
  end

  test "touches last_request_at when missing" do
    now = Time.zone.local(2026, 6, 23, 12, 0, 0)
    user = create(:user, last_request_at: nil)

    travel_to now do
      user.touch_last_request_at_if_stale
    end

    assert_equal now, user.last_request_at
    assert_not user.has_changes_to_save?
    assert_equal now, user.reload.last_request_at
  end

  test "does not touch last_request_at when newer than one minute" do
    now = Time.zone.local(2026, 6, 23, 12, 0, 0)
    existing_last_request_at = now - 30.seconds
    user = create(:user, last_request_at: existing_last_request_at)

    travel_to now do
      user.touch_last_request_at_if_stale
    end

    assert_equal existing_last_request_at, user.reload.last_request_at
  end

  test "does not touch last_request_at when exactly one minute old" do
    now = Time.zone.local(2026, 6, 23, 12, 0, 0)
    existing_last_request_at = now - 1.minute
    user = create(:user, last_request_at: existing_last_request_at)

    travel_to now do
      user.touch_last_request_at_if_stale
    end

    assert_equal existing_last_request_at, user.reload.last_request_at
  end

  test "touches last_request_at when older than one minute" do
    now = Time.zone.local(2026, 6, 23, 12, 0, 0)
    user = create(:user, last_request_at: now - 61.seconds)

    travel_to now do
      user.touch_last_request_at_if_stale
    end

    assert_equal now, user.last_request_at
    assert_not user.has_changes_to_save?
    assert_equal now, user.reload.last_request_at
  end
end
