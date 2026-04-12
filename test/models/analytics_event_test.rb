# typed: true
# frozen_string_literal: true

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
end
