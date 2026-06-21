# typed: true
# frozen_string_literal: true

require "test_helper"

class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "creates ios app feedback with valid params" do
    params = attributes_for(:feedback)

    assert_difference "Feedback.count", 1 do
      post feedbacks_url,
           params: { feedback: params },
           headers: auth_headers
    end

    assert_response :created

    feedback = Feedback.last!

    assert_equal params[:email], feedback.email
    assert_equal params[:message], feedback.message
    assert_equal Feedback::IOS_APP_SOURCE, feedback.source
    assert_equal test_user.id, feedback.user_id
  end

  test "creates anonymous web contact feedback" do
    params = attributes_for(
      :feedback,
      source: Feedback::WEB_CONTACT_SOURCE,
      user: nil,
    )

    assert_difference "Feedback.count", 1 do
      post feedbacks_url,
           params: { feedback: params }
    end

    assert_response :created

    feedback = Feedback.last!

    assert_equal params[:email], feedback.email
    assert_equal params[:message], feedback.message
    assert_equal Feedback::WEB_CONTACT_SOURCE, feedback.source
    assert_nil feedback.user_id
  end

  test "allows web contact cors preflight" do
    options feedbacks_url,
            headers: {
              "Origin" => "https://fren.day",
              "Access-Control-Request-Method" => "POST",
            }

    assert_response :no_content
    assert_equal "https://fren.day", response.headers["Access-Control-Allow-Origin"]
    assert_equal "POST, OPTIONS", response.headers["Access-Control-Allow-Methods"]
  end

  test "creates feedback without email" do
    params = attributes_for(:feedback, email: nil)

    assert_difference "Feedback.count", 1 do
      post feedbacks_url,
           params: { feedback: params },
           headers: auth_headers
    end

    assert_response :created
  end

  test "returns error when message is missing" do
    params = attributes_for(:feedback, message: nil)

    assert_no_difference "Feedback.count" do
      post feedbacks_url,
           params: { feedback: params },
           headers: auth_headers
    end

    assert_response :unprocessable_content
    assert_includes response_json["errors"], "Message can't be blank"
  end

  test "returns error when message is too short" do
    params = attributes_for(:feedback, message: "Too short")

    assert_no_difference "Feedback.count" do
      post feedbacks_url,
           params: { feedback: params },
           headers: auth_headers
    end

    assert_response :unprocessable_content
    assert_includes response_json["errors"], "Message is too short (minimum is 10 characters)"
  end

  test "returns validation error for ios app feedback without X-User-Id header" do
    params = attributes_for(:feedback)

    post feedbacks_url,
         params: { feedback: params }

    assert_response :unprocessable_content
    assert_includes response_json["errors"], "User must exist"
  end

  test "returns unauthorized with invalid X-User-Id header" do
    params = attributes_for(:feedback)

    post feedbacks_url,
         params: { feedback: params },
         headers: { "X-User-Id" => "invalid" }

    assert_response :unauthorized
    assert_equal "X-User-Id header must be a valid UUID", response_json.dig("error", "message")
    assert_equal "authentication_failed", response_json.dig("error", "code")
  end
end
