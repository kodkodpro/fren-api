# typed: true
# frozen_string_literal: true

require "test_helper"

class ProxyControllerTest < ActionDispatch::IntegrationTest
  setup do
    @openai_base = Env.openai_api_url
    @openai_key = Env.openai_api_key
  end

  test "forwards GET requests and returns upstream response" do
    stub_request(:get, "#{@openai_base}/v1/models")
      .to_return(status: 200, body: '{"data":[]}', headers: { "Content-Type" => "application/json" })

    get proxy_openai_url(path: "v1/models"), headers: proxy_headers

    assert_response :success
    assert_equal '{"data":[]}', response.body
  end

  test "forwards POST requests with body" do
    request_body = '{"model":"gpt-4","messages":[{"role":"user","content":"hi"}]}'

    stub_request(:post, "#{@openai_base}/v1/chat/completions")
      .with(body: request_body)
      .to_return(status: 200, body: '{"choices":[]}', headers: { "Content-Type" => "application/json" })

    post proxy_openai_url(path: "v1/chat/completions"),
         params: request_body,
         headers: proxy_headers.merge("Content-Type" => "application/json")

    assert_response :success
    assert_equal '{"choices":[]}', response.body
  end

  test "injects Authorization header with Bearer token" do
    stub_request(:get, "#{@openai_base}/v1/models")
      .with(headers: { "Authorization" => "Bearer #{@openai_key}" })
      .to_return(status: 200, body: "{}")

    get proxy_openai_url(path: "v1/models"), headers: proxy_headers

    assert_response :success
  end

  test "forwards PUT requests" do
    stub_request(:put, "#{@openai_base}/v1/some/resource")
      .to_return(status: 200, body: '{"updated":true}')

    put proxy_openai_url(path: "v1/some/resource"),
        params: '{"name":"test"}',
        headers: proxy_headers.merge("Content-Type" => "application/json")

    assert_response :success
  end

  test "forwards PATCH requests" do
    stub_request(:patch, "#{@openai_base}/v1/some/resource")
      .to_return(status: 200, body: '{"patched":true}')

    patch proxy_openai_url(path: "v1/some/resource"),
          params: '{"name":"test"}',
          headers: proxy_headers.merge("Content-Type" => "application/json")

    assert_response :success
  end

  test "forwards DELETE requests" do
    stub_request(:delete, "#{@openai_base}/v1/some/resource")
      .to_return(status: 200, body: '{"deleted":true}')

    delete proxy_openai_url(path: "v1/some/resource"), headers: proxy_headers

    assert_response :success
  end

  test "preserves query parameters" do
    stub_request(:get, "#{@openai_base}/v1/models")
      .with(query: { "limit" => "5", "order" => "desc" })
      .to_return(status: 200, body: '{"data":[]}')

    get proxy_openai_url(path: "v1/models"), params: { limit: 5, order: "desc" }, headers: proxy_headers

    assert_response :success
  end

  test "returns upstream 401 error as-is" do
    stub_request(:get, "#{@openai_base}/v1/models")
      .to_return(status: 401, body: '{"error":"unauthorized"}')

    get proxy_openai_url(path: "v1/models"), headers: proxy_headers

    assert_response :unauthorized
  end

  test "forwards multipart/form-data POST requests" do
    stub_request(:post, "#{@openai_base}/v1/audio/transcriptions")
      .to_return(status: 200, body: '{"text":"hello"}', headers: { "Content-Type" => "application/json" })

    boundary = "----TestBoundary1234"
    multipart_body = [
      "--#{boundary}",
      'Content-Disposition: form-data; name="model"',
      "",
      "whisper-1",
      "--#{boundary}",
      'Content-Disposition: form-data; name="language"',
      "",
      "uk",
      "--#{boundary}--",
    ].join("\r\n")

    post proxy_openai_url(path: "v1/audio/transcriptions"),
         params: multipart_body,
         headers: proxy_headers.merge("Content-Type" => "multipart/form-data; boundary=#{boundary}")

    assert_response :success
    assert_equal '{"text":"hello"}', response.body
  end

  test "returns upstream 500 error as-is" do
    stub_request(:get, "#{@openai_base}/v1/models")
      .to_return(status: 500, body: '{"error":"internal server error"}')

    get proxy_openai_url(path: "v1/models"), headers: proxy_headers

    assert_response :internal_server_error
  end

  test "notifies Sentry on non-successful upstream response" do
    spy = Spy.on(Sentry, :capture_message)

    stub_request(:get, "#{@openai_base}/v1/models")
      .to_return(status: 500, body: '{"error":"internal server error"}')

    get proxy_openai_url(path: "v1/models"), headers: proxy_headers

    assert_spy_called spy
    assert_equal "OpenAI Proxy Error", spy.calls.first.args.first
  end

  test "does not notify Sentry on successful upstream response" do
    spy = Spy.on(Sentry, :capture_message)

    stub_request(:get, "#{@openai_base}/v1/models")
      .to_return(status: 200, body: '{"data":[]}', headers: { "Content-Type" => "application/json" })

    get proxy_openai_url(path: "v1/models"), headers: proxy_headers

    assert_spy_not_called spy
  end

  # AI access gate

  test "allows requests without a transaction id when billing is disabled" do
    stub_request(:get, "#{@openai_base}/v1/models")
      .to_return(status: 200, body: '{"data":[]}', headers: { "Content-Type" => "application/json" })

    get proxy_openai_url(path: "v1/models"), headers: auth_headers

    assert_response :success
    assert_equal '{"data":[]}', response.body
  end

  test "allows requests with free memo quota when billing is enabled" do
    user = create(:user, free_memos_available: 1)
    Spy.on(Env, :enable_billing).and_return(true)

    stub_request(:get, "#{@openai_base}/v1/models")
      .to_return(status: 200, body: '{"data":[]}', headers: { "Content-Type" => "application/json" })

    assert_no_difference -> { user.reload.free_memos_available } do
      get proxy_openai_url(path: "v1/models"), headers: auth_headers(user)
    end

    assert_response :success
    assert_equal '{"data":[]}', response.body
  end

  test "returns 402 when no active subscription or free memo quota is available" do
    user = create(:user, free_memos_available: 0)
    Spy.on(Env, :enable_billing).and_return(true)

    get proxy_openai_url(path: "v1/models"), headers: auth_headers(user)

    assert_response :payment_required
    assert_equal "Active subscription or free memo quota is required", response_json.dig("error", "message")
    assert_equal "subscription_required", response_json.dig("error", "code")
  end

  test "returns 402 when the subscription is expired and quota is exhausted" do
    user = create(:user, free_memos_available: 0)
    create(:subscription, :expired, user:, transaction_id: "tx-expired")
    Spy.on(Env, :enable_billing).and_return(true)

    get proxy_openai_url(path: "v1/models"),
        headers: auth_headers(user).merge("X-iOS-Transaction-Id" => "tx-expired")

    assert_response :payment_required
    assert_equal "Active subscription or free memo quota is required", response_json.dig("error", "message")
    assert_equal "subscription_required", response_json.dig("error", "code")
  end

  test "returns 402 when the subscription is revoked and quota is exhausted" do
    user = create(:user, free_memos_available: 0)
    create(:subscription, :revoked, user:, transaction_id: "tx-revoked")
    Spy.on(Env, :enable_billing).and_return(true)

    get proxy_openai_url(path: "v1/models"),
        headers: auth_headers(user).merge("X-iOS-Transaction-Id" => "tx-revoked")

    assert_response :payment_required
    assert_equal "subscription_required", response_json.dig("error", "code")
  end

  test "allows requests when the subscription is in the grace period and quota is exhausted" do
    user = create(:user, free_memos_available: 0)
    create(:subscription, :in_grace_period, user:, transaction_id: "tx-grace")
    Spy.on(Env, :enable_billing).and_return(true)

    stub_request(:get, "#{@openai_base}/v1/models")
      .to_return(status: 200, body: '{"data":[]}', headers: { "Content-Type" => "application/json" })

    get proxy_openai_url(path: "v1/models"),
        headers: auth_headers(user).merge("X-iOS-Transaction-Id" => "tx-grace")

    assert_response :success
  end

  test "returns 402 when Apple returns an error during refresh and quota is exhausted" do
    user = create(:user, free_memos_available: 0)
    create(:subscription, :active, :stale, user:, transaction_id: "tx-apple-down")
    Spy.on(Env, :enable_billing).and_return(true)

    stub_request(:get, /api.storekit-sandbox.itunes.apple.com/)
      .to_return(status: 500, body: "{}")

    get proxy_openai_url(path: "v1/models"),
        headers: auth_headers(user).merge("X-iOS-Transaction-Id" => "tx-apple-down")

    assert_response :payment_required
    assert_equal "Unable to verify subscription", response_json.dig("error", "message")
    assert_equal "subscription_verification_failed", response_json.dig("error", "code")
  end
end
