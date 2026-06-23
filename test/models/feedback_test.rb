# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: feedbacks
#
#  id         :bigint           not null, primary key
#  email      :text
#  message    :text             not null
#  source     :string           default("ios-app"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :uuid
#
# Indexes
#
#  index_feedbacks_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class FeedbackTest < ActiveSupport::TestCase
  test "valid with user message and ios app source" do
    feedback = build(:feedback)

    assert_predicate feedback, :valid?
  end

  test "ios app source is invalid without user" do
    feedback = build(:feedback, user: nil)

    assert_not feedback.valid?
    assert_includes feedback.errors[:user], "must exist"
  end

  test "web contact source is valid without user" do
    feedback = build(:feedback, user: nil, source: Feedback::WEB_CONTACT_SOURCE)

    assert_predicate feedback, :valid?
  end

  test "invalid with unknown source" do
    feedback = build(:feedback, source: "unknown")

    assert_not feedback.valid?
    assert_includes feedback.errors[:source], "is not included in the list"
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
