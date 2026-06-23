# typed: true
# frozen_string_literal: true

require "test_helper"

class ProxyControllerTest < ActionDispatch::IntegrationTest
  setup do
    @openai_base = Env.openai_api_url
    @openai_key = Env.openai_api_key
  end

  test "forwards allowed chat completion POST requests with app prompt body" do
    request_body = chat_body

    stub_request(:post, "#{@openai_base}/v1/chat/completions")
      .with(body: request_body)
      .to_return(status: 200, body: '{"choices":[]}', headers: { "Content-Type" => "application/json" })

    post proxy_openai_url(path: "v1/chat/completions"),
         params: request_body,
         headers: proxy_headers.merge("Content-Type" => "application/json")

    assert_response :success
    assert_equal '{"choices":[]}', response.body
  end

  test "injects Authorization header with Bearer token for allowed requests" do
    stub_request(:post, "#{@openai_base}/v1/chat/completions")
      .with(headers: { "Authorization" => "Bearer #{@openai_key}" })
      .to_return(status: 200, body: "{}")

    post proxy_openai_url(path: "v1/chat/completions"),
         params: chat_body,
         headers: proxy_headers.merge("Content-Type" => "application/json")

    assert_response :success
  end

  test "preserves query parameters for allowed requests" do
    stub_request(:post, "#{@openai_base}/v1/chat/completions")
      .with(query: { "limit" => "5", "order" => "desc" })
      .to_return(status: 200, body: '{"choices":[]}')

    post proxy_openai_url(path: "v1/chat/completions", limit: 5, order: "desc"),
         params: chat_body,
         headers: proxy_headers.merge("Content-Type" => "application/json")

    assert_response :success
  end

  test "allows chat prompt content nested inside an array payload" do
    request_body = chat_body(content: [type: "text", text: valid_prompt_text])

    stub_request(:post, "#{@openai_base}/v1/chat/completions")
      .with(body: request_body)
      .to_return(status: 200, body: '{"choices":[]}', headers: { "Content-Type" => "application/json" })

    post proxy_openai_url(path: "v1/chat/completions"),
         params: request_body,
         headers: proxy_headers.merge("Content-Type" => "application/json")

    assert_response :success
  end

  test "rejects chat completions without known app prompt text" do
    spy = Spy.on(Sentry, :capture_message)
    request_body = JSON.generate(model: "gpt-5.4", messages: [role: "user", content: "hi"])

    post proxy_openai_url(path: "v1/chat/completions"),
         params: request_body,
         headers: proxy_headers.merge("Content-Type" => "application/json")

    assert_response :forbidden
    assert_equal({ "error" => "forbidden" }, response_json)
    assert_not_requested :post, "#{@openai_base}/v1/chat/completions"
    assert_spy_called spy
    assert_equal "OpenAI Proxy Request Blocked", spy.calls.first.args.first
  end

  test "rejects malformed chat completion JSON" do
    spy = Spy.on(Sentry, :capture_message)

    post proxy_openai_url(path: "v1/chat/completions"),
         params: "{",
         headers: proxy_headers.merge("Content-Type" => "application/json")

    assert_response :forbidden
    assert_equal({ "error" => "forbidden" }, response_json)
    assert_not_requested :post, "#{@openai_base}/v1/chat/completions"
    assert_spy_called spy
  end

  test "forwards multipart/form-data transcription requests without prompt checks" do
    stub_request(:post, "#{@openai_base}/v1/audio/transcriptions")
      .to_return(status: 200, body: '{"text":"hello"}', headers: { "Content-Type" => "application/json" })

    boundary = "----TestBoundary1234"

    post proxy_openai_url(path: "v1/audio/transcriptions"),
         params: multipart_body(boundary:),
         headers: proxy_headers.merge("Content-Type" => "multipart/form-data; boundary=#{boundary}")

    assert_response :success
    assert_equal '{"text":"hello"}', response.body
  end

  test "rejects unknown OpenAI GET paths" do
    get proxy_openai_url(path: "v1/models"), headers: proxy_headers

    assert_response :forbidden
    assert_equal({ "error" => "forbidden" }, response_json)
    assert_not_requested :get, "#{@openai_base}/v1/models"
  end

  test "rejects unknown OpenAI mutating paths" do
    put proxy_openai_url(path: "v1/some/resource"),
        params: '{"name":"test"}',
        headers: proxy_headers.merge("Content-Type" => "application/json")

    assert_response :forbidden
    assert_equal({ "error" => "forbidden" }, response_json)
    assert_not_requested :put, "#{@openai_base}/v1/some/resource"
  end

  test "notifies Sentry without request body on blocked requests" do
    spy = Spy.on(Sentry, :capture_message)
    request_body = JSON.generate(model: "gpt-5.4", messages: [role: "user", content: "attack prompt"])

    post proxy_openai_url(path: "v1/chat/completions"),
         params: request_body,
         headers: proxy_headers.merge("Content-Type" => "application/json")

    assert_spy_called spy

    call = spy.calls.first

    assert_equal "OpenAI Proxy Request Blocked", call.args.first
    assert_equal :warning, call.kwargs[:level]
    assert_equal "missing_prompt_fragment", call.kwargs.dig(:extra, :reason)
    assert_equal "POST", call.kwargs.dig(:extra, :method)
    assert_equal "/proxy/openai/v1/chat/completions", call.kwargs.dig(:extra, :path)
    assert_nil call.kwargs.dig(:extra, :body)
    assert_nil call.kwargs.dig(:extra, :raw_body)
    assert_not_includes call.kwargs.inspect, "attack prompt"
  end

  test "returns upstream 401 error as-is for allowed requests" do
    stub_request(:post, "#{@openai_base}/v1/chat/completions")
      .to_return(status: 401, body: '{"error":"unauthorized"}')

    post proxy_openai_url(path: "v1/chat/completions"),
         params: chat_body,
         headers: proxy_headers.merge("Content-Type" => "application/json")

    assert_response :unauthorized
  end

  test "returns upstream 500 error as-is for allowed requests" do
    stub_request(:post, "#{@openai_base}/v1/chat/completions")
      .to_return(status: 500, body: '{"error":"internal server error"}')

    post proxy_openai_url(path: "v1/chat/completions"),
         params: chat_body,
         headers: proxy_headers.merge("Content-Type" => "application/json")

    assert_response :internal_server_error
  end

  test "notifies Sentry on non-successful upstream response for allowed requests" do
    spy = Spy.on(Sentry, :capture_message)

    stub_request(:post, "#{@openai_base}/v1/chat/completions")
      .to_return(status: 500, body: '{"error":"internal server error"}')

    post proxy_openai_url(path: "v1/chat/completions"),
         params: chat_body,
         headers: proxy_headers.merge("Content-Type" => "application/json")

    assert_spy_called spy
    assert_equal "OpenAI Proxy Error", spy.calls.first.args.first
  end

  test "does not notify Sentry on successful upstream response" do
    spy = Spy.on(Sentry, :capture_message)

    stub_request(:post, "#{@openai_base}/v1/chat/completions")
      .to_return(status: 200, body: '{"choices":[]}', headers: { "Content-Type" => "application/json" })

    post proxy_openai_url(path: "v1/chat/completions"),
         params: chat_body,
         headers: proxy_headers.merge("Content-Type" => "application/json")

    assert_spy_not_called spy
  end

  # AI access gate

  test "allows requests without a transaction id when billing is disabled" do
    stub_request(:post, "#{@openai_base}/v1/audio/transcriptions")
      .to_return(status: 200, body: '{"text":"hello"}', headers: { "Content-Type" => "application/json" })

    boundary = "----TestBoundary1234"

    post proxy_openai_url(path: "v1/audio/transcriptions"),
         params: multipart_body(boundary:),
         headers: auth_headers.merge("Content-Type" => "multipart/form-data; boundary=#{boundary}")

    assert_response :success
    assert_equal '{"text":"hello"}', response.body
  end

  test "allows requests with free AI analysis when billing is enabled" do
    user = create(:user, free_ai_analyses_available: 1)
    Spy.on(Env, :enable_billing).and_return(true)

    stub_request(:post, "#{@openai_base}/v1/audio/transcriptions")
      .to_return(status: 200, body: '{"text":"hello"}', headers: { "Content-Type" => "application/json" })

    boundary = "----TestBoundary1234"

    assert_no_difference -> { user.reload.free_ai_analyses_available } do
      post proxy_openai_url(path: "v1/audio/transcriptions"),
           params: multipart_body(boundary:),
           headers: auth_headers(user).merge("Content-Type" => "multipart/form-data; boundary=#{boundary}")
    end

    assert_response :success
    assert_equal '{"text":"hello"}', response.body
  end

  test "returns 402 for free AI analysis when free AI analysis is disabled" do
    user = create(:user, free_ai_analyses_available: 1)
    Spy.on(Env, :enable_billing).and_return(true)
    Spy.on(Env, :disable_free_ai_analysis).and_return(true)

    get proxy_openai_url(path: "v1/models"), headers: auth_headers(user)

    assert_response :payment_required
    assert_equal "Active subscription or free AI analysis is required", response_json.dig("error", "message")
    assert_equal "subscription_required", response_json.dig("error", "code")
  end

  test "allows active subscription when free AI analysis is disabled" do
    user = create(:user, free_ai_analyses_available: 0)
    Spy.on(Env, :enable_billing).and_return(true)
    Spy.on(Env, :disable_free_ai_analysis).and_return(true)

    stub_request(:post, "#{@openai_base}/v1/audio/transcriptions")
      .to_return(status: 200, body: '{"text":"hello"}', headers: { "Content-Type" => "application/json" })

    boundary = "----TestBoundary1234"

    post proxy_openai_url(path: "v1/audio/transcriptions"),
         params: multipart_body(boundary:),
         headers: proxy_headers(user, transaction_id: "tx-active-disabled-analysis").merge("Content-Type" => "multipart/form-data; boundary=#{boundary}")

    assert_response :success
    assert_equal '{"text":"hello"}', response.body
  end

  test "returns 402 when no active subscription or free AI analysis is available" do
    user = create(:user, free_ai_analyses_available: 0)
    Spy.on(Env, :enable_billing).and_return(true)

    get proxy_openai_url(path: "v1/models"), headers: auth_headers(user)

    assert_response :payment_required
    assert_equal "Active subscription or free AI analysis is required", response_json.dig("error", "message")
    assert_equal "subscription_required", response_json.dig("error", "code")
  end

  test "returns 402 when the subscription is expired and free AI analysis is exhausted" do
    user = create(:user, free_ai_analyses_available: 0)
    create(:subscription, :expired, user:, transaction_id: "tx-expired")
    Spy.on(Env, :enable_billing).and_return(true)

    get proxy_openai_url(path: "v1/models"),
        headers: auth_headers(user).merge("X-iOS-Transaction-Id" => "tx-expired")

    assert_response :payment_required
    assert_equal "Active subscription or free AI analysis is required", response_json.dig("error", "message")
    assert_equal "subscription_required", response_json.dig("error", "code")
  end

  test "returns 402 when the subscription is revoked and free AI analysis is exhausted" do
    user = create(:user, free_ai_analyses_available: 0)
    create(:subscription, :revoked, user:, transaction_id: "tx-revoked")
    Spy.on(Env, :enable_billing).and_return(true)

    get proxy_openai_url(path: "v1/models"),
        headers: auth_headers(user).merge("X-iOS-Transaction-Id" => "tx-revoked")

    assert_response :payment_required
    assert_equal "subscription_required", response_json.dig("error", "code")
  end

  test "allows requests when the subscription is in the grace period and free AI analysis is exhausted" do
    user = create(:user, free_ai_analyses_available: 0)
    create(:subscription, :in_grace_period, user:, transaction_id: "tx-grace")
    Spy.on(Env, :enable_billing).and_return(true)

    stub_request(:post, "#{@openai_base}/v1/audio/transcriptions")
      .to_return(status: 200, body: '{"text":"hello"}', headers: { "Content-Type" => "application/json" })

    boundary = "----TestBoundary1234"

    post proxy_openai_url(path: "v1/audio/transcriptions"),
         params: multipart_body(boundary:),
         headers: auth_headers(user).merge(
           "X-iOS-Transaction-Id" => "tx-grace",
           "Content-Type" => "multipart/form-data; boundary=#{boundary}",
         )

    assert_response :success
  end

  test "returns 402 when Apple returns an error during refresh and free AI analysis is exhausted" do
    user = create(:user, free_ai_analyses_available: 0)
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

  private

  def chat_body(content: valid_prompt_text)
    JSON.generate(
      model: "gpt-5.4",
      messages: [
        role: "system",
        content:,
      ],
    )
  end

  def valid_prompt_text
    [
      "You are helping to build a memo tracking application for people with ADHD and similar challenges. Your task is to analyze a voice memo transcript and generate a concise title and representative emoji for it.",
      "Here is the memo text to analyze:",
      "Your final output should contain only the title and emoji tags with their respective content.",
    ].join("\n")
  end

  def multipart_body(boundary:)
    [
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
  end
end
