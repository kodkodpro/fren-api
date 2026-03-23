# typed: true
# frozen_string_literal: true

require "test_helper"

class FeedbackTest < ActiveSupport::TestCase
  test "valid with user and message" do
    feedback = build(:feedback)

    assert_predicate feedback, :valid?
  end

  test "invalid without user" do
    feedback = build(:feedback, user: nil)

    assert_not feedback.valid?
  end

  test "invalid without message" do
    feedback = build(:feedback, message: nil)

    assert_not feedback.valid?
    assert_includes feedback.errors[:message], "can't be blank"
  end

  test "invalid with message shorter than 10 characters" do
    feedback = build(:feedback, message: "Too short")

    assert_not feedback.valid?
    assert_includes feedback.errors[:message], "is too short (minimum is 10 characters)"
  end

  test "valid without email" do
    feedback = build(:feedback, email: nil)

    assert_predicate feedback, :valid?
    assert_nil feedback.email
  end

  test "valid with email" do
    feedback = build(:feedback)

    assert_predicate feedback, :valid?
  end
end
