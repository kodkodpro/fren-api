# typed: true
# frozen_string_literal: true

require "test_helper"

class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "creates feedback with valid params" do
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
    assert_equal test_user.id, feedback.user_id
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

  test "returns unauthorized without X-User-Id header" do
    params = attributes_for(:feedback)

    post feedbacks_url,
         params: { feedback: params }

    assert_response :unauthorized
    assert_equal "X-User-Id header is required", response_json["error"]
  end
end
