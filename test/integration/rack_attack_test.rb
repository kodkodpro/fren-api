# typed: true
# frozen_string_literal: true

require "test_helper"

# rubocop:disable Minitest/EmptyLineBeforeAssertionMethods
class RackAttackTest < ActionDispatch::IntegrationTest
  setup do
    Rack::Attack.cache.store.clear
    @openai_base = Env.openai_api_url
    stub_request(:any, /#{Regexp.escape(@openai_base)}/).to_return(status: 200, body: "{}")
  end

  test "health check is safelisted and never throttles" do
    400.times do
      get "/up"
      assert_response :success
    end
  end

  test "proxy/openai throttles by user id after 20 req/min" do
    headers = proxy_headers

    20.times do |i|
      post_openai_transcription(headers:)
      assert_response :success, "request ##{i + 1} should succeed"
    end

    post_openai_transcription(headers:)

    assert_response :too_many_requests
    assert_equal "rate_limited", response_json["error"]
    assert_predicate response_json["retry_after"].to_i, :positive?
    assert_predicate response.headers["Retry-After"].to_i, :positive?
  end

  test "proxy/openai buckets are independent per user" do
    user_a = create(:user)
    user_b = create(:user)
    headers_a = proxy_headers(user_a)
    headers_b = proxy_headers(user_b)

    20.times do
      post_openai_transcription(headers: headers_a)
      assert_response :success
    end

    post_openai_transcription(headers: headers_a)
    assert_response :too_many_requests

    post_openai_transcription(headers: headers_b)
    assert_response :success
  end

  test "proxy/openai falls back to IP throttling without X-User-Id header" do
    # Without X-User-Id the app raises, but Rack::Attack matches first and
    # counts by IP. We only assert that the throttle key path works: the 21st
    # request gets 429 instead of the usual raise.
    20.times do
      post_openai_transcription(headers: {})
    rescue RuntimeError
      # ApplicationController raises before the controller renders. That's
      # expected pre-throttle; we only care the request was counted.
    end

    post_openai_transcription(headers: {})
    assert_response :too_many_requests
  end

  test "feedbacks#create throttles after 5 req/min" do
    headers = auth_headers

    5.times do
      post(feedbacks_url, params: { feedback: attributes_for(:feedback) }, headers:)
      assert_response :created
    end

    post(feedbacks_url, params: { feedback: attributes_for(:feedback) }, headers:)
    assert_response :too_many_requests
  end

  test "remote-config throttles after 30 req/min" do
    headers = auth_headers

    30.times do
      get(remote_config_url, headers:)
      assert_response :success
    end

    get(remote_config_url, headers:)
    assert_response :too_many_requests
  end

  test "throttled request notifies Sentry with the matched rule" do
    headers = proxy_headers
    capture_message_spy = Spy.on(Sentry, :capture_message)

    21.times { post_openai_transcription(headers:) }

    assert_response :too_many_requests
    assert_spy_called capture_message_spy, "Sentry.capture_message was not called"
  end

  private

  def post_openai_transcription(headers:)
    boundary = "----TestBoundary1234"

    post proxy_openai_url(path: "v1/audio/transcriptions"),
         params: multipart_body(boundary:),
         headers: headers.merge("Content-Type" => "multipart/form-data; boundary=#{boundary}")
  end

  def multipart_body(boundary:)
    [
      "--#{boundary}",
      'Content-Disposition: form-data; name="model"',
      "",
      "whisper-1",
      "--#{boundary}--",
    ].join("\r\n")
  end
end
# rubocop:enable Minitest/EmptyLineBeforeAssertionMethods
