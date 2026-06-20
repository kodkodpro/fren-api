# typed: true
# frozen_string_literal: true

require "test_helper"

class FreeMemoQuota::ConsumeTest < ActiveSupport::TestCase
  test "decrements available free memo quota" do
    user = create(:user, free_memos_available: 2)

    assert_difference -> { user.reload.free_memos_available }, -1 do
      FreeMemoQuota::Consume.run!(user:)
    end
  end

  test "raises when quota is exhausted" do
    user = create(:user, free_memos_available: 0)

    assert_no_difference -> { user.reload.free_memos_available } do
      assert_raises(Fren::FreeMemoQuotaExhaustedError) do
        FreeMemoQuota::Consume.run!(user:)
      end
    end
  end

  test "consumes the final memo once" do
    user = create(:user, free_memos_available: 1)

    FreeMemoQuota::Consume.run!(user:)

    assert_equal 0, user.reload.free_memos_available

    assert_no_difference -> { user.reload.free_memos_available } do
      assert_raises(Fren::FreeMemoQuotaExhaustedError) do
        FreeMemoQuota::Consume.run!(user:)
      end
    end
  end
end
