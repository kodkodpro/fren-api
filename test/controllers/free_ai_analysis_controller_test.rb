# typed: true
# frozen_string_literal: true

require "test_helper"

class FreeAIAnalysisControllerTest < ActionDispatch::IntegrationTest
  test "returns the current user's free AI analyses" do
    user = create(:user, free_ai_analyses_available: 2)

    get free_ai_analysis_url, headers: auth_headers(user)

    assert_response :success
    assert_equal({ "available" => 2 }, response_json)
  end

  test "consumes one free AI analysis" do
    user = create(:user, free_ai_analyses_available: 2)

    assert_difference -> { user.reload.free_ai_analyses_available }, -1 do
      post consume_free_ai_analysis_url, headers: auth_headers(user)
    end

    assert_response :success
    assert_equal({ "available" => 1 }, response_json)
  end

  test "returns 402 when free AI analysis is exhausted" do
    user = create(:user, free_ai_analyses_available: 0)

    assert_no_difference -> { user.reload.free_ai_analyses_available } do
      post consume_free_ai_analysis_url, headers: auth_headers(user)
    end

    assert_response :payment_required
    assert_equal "Free AI analysis exhausted", response_json.dig("error", "message")
    assert_equal "free_ai_analysis_exhausted", response_json.dig("error", "code")
  end

  test "returns 402 without consuming when free AI analysis is disabled" do
    user = create(:user, free_ai_analyses_available: 2)
    Spy.on(Env, :disable_free_ai_analysis).and_return(true)

    assert_no_difference -> { user.reload.free_ai_analyses_available } do
      post consume_free_ai_analysis_url, headers: auth_headers(user)
    end

    assert_response :payment_required
    assert_equal "Free AI analysis exhausted", response_json.dig("error", "message")
    assert_equal "free_ai_analysis_exhausted", response_json.dig("error", "code")
  end
end
