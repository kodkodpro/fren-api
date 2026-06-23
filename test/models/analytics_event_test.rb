# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: analytics_events
#
#  id          :bigint           not null, primary key
#  name        :integer          not null
#  occurred_at :datetime         not null
#  properties  :jsonb
#  tier        :integer          default("unknown"), not null
#  created_at  :datetime         not null
#  user_id     :uuid             not null
#
# Indexes
#
#  index_analytics_events_on_name         (name)
#  index_analytics_events_on_occurred_at  (occurred_at)
#  index_analytics_events_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class AnalyticsEventTest < ActiveSupport::TestCase
  test "valid with all attributes" do
    event = build(:analytics_event)

    assert_predicate event, :valid?
  end

  test "invalid without user" do
    event = build(:analytics_event, user: nil)

    assert_not event.valid?
  end

  test "invalid without name" do
    event = build(:analytics_event, name: nil)

    assert_not event.valid?
  end

  test "invalid with unknown event name" do
    event = build(:analytics_event, name: 999)

    assert_not event.valid?
  end

  test "invalid without occurred_at" do
    event = build(:analytics_event, occurred_at: nil)

    assert_not event.valid?
  end

  test "invalid without tier" do
    event = build(:analytics_event, tier: nil)

    assert_not event.valid?
  end

  test "stores tier as the T enum integer" do
    event = create(:analytics_event, tier: Analytics::Tier::Trial)

    assert_equal Analytics::Tier::Trial, event.tier
    assert_equal Analytics::Tier::Trial.serialize, event.read_attribute_before_type_cast(:tier)
  end
end
