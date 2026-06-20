# typed: true
# frozen_string_literal: true

require "test_helper"

class FreeMemoQuotaControllerTest < ActionDispatch::IntegrationTest
  test "returns the current user's free memo quota" do
    user = create(:user, free_memos_available: 2)

    get free_memo_quota_url, headers: auth_headers(user)

    assert_response :success
    assert_equal 2, response_json["available"]
    assert response_json["can_record"]
  end

  test "can_record is false when quota is exhausted" do
    user = create(:user, free_memos_available: 0)

    get free_memo_quota_url, headers: auth_headers(user)

    assert_response :success
    assert_not response_json["can_record"]
  end

  test "can_record is false when free memo quota is disabled" do
    user = create(:user, free_memos_available: 2)
    Spy.on(Env, :disable_free_memos_quota).and_return(true)

    get free_memo_quota_url, headers: auth_headers(user)

    assert_response :success
    assert_equal 2, response_json["available"]
    assert_not response_json["can_record"]
  end

  test "consumes one free memo" do
    user = create(:user, free_memos_available: 2)

    assert_difference -> { user.reload.free_memos_available }, -1 do
      post consume_free_memo_quota_url, headers: auth_headers(user)
    end

    assert_response :success
    assert_equal 1, response_json["available"]
    assert response_json["can_record"]
  end

  test "returns 402 when quota is exhausted" do
    user = create(:user, free_memos_available: 0)

    assert_no_difference -> { user.reload.free_memos_available } do
      post consume_free_memo_quota_url, headers: auth_headers(user)
    end

    assert_response :payment_required
    assert_equal "Free memo quota exhausted", response_json.dig("error", "message")
    assert_equal "free_memo_quota_exhausted", response_json.dig("error", "code")
  end

  test "returns 402 without consuming when free memo quota is disabled" do
    user = create(:user, free_memos_available: 2)
    Spy.on(Env, :disable_free_memos_quota).and_return(true)

    assert_no_difference -> { user.reload.free_memos_available } do
      post consume_free_memo_quota_url, headers: auth_headers(user)
    end

    assert_response :payment_required
    assert_equal "Free memo quota exhausted", response_json.dig("error", "message")
    assert_equal "free_memo_quota_exhausted", response_json.dig("error", "code")
  end
end
