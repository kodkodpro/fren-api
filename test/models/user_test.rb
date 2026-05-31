# typed: true
# frozen_string_literal: true

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
end
