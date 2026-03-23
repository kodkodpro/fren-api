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

    get proxy_openai_url(path: "v1/models"), headers: auth_headers

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
         headers: auth_headers.merge("Content-Type" => "application/json")

    assert_response :success
    assert_equal '{"choices":[]}', response.body
  end

  test "injects Authorization header with Bearer token" do
    stub_request(:get, "#{@openai_base}/v1/models")
      .with(headers: { "Authorization" => "Bearer #{@openai_key}" })
      .to_return(status: 200, body: "{}")

    get proxy_openai_url(path: "v1/models"), headers: auth_headers

    assert_response :success
  end

  test "forwards PUT requests" do
    stub_request(:put, "#{@openai_base}/v1/some/resource")
      .to_return(status: 200, body: '{"updated":true}')

    put proxy_openai_url(path: "v1/some/resource"),
        params: '{"name":"test"}',
        headers: auth_headers.merge("Content-Type" => "application/json")

    assert_response :success
  end

  test "forwards PATCH requests" do
    stub_request(:patch, "#{@openai_base}/v1/some/resource")
      .to_return(status: 200, body: '{"patched":true}')

    patch proxy_openai_url(path: "v1/some/resource"),
          params: '{"name":"test"}',
          headers: auth_headers.merge("Content-Type" => "application/json")

    assert_response :success
  end

  test "forwards DELETE requests" do
    stub_request(:delete, "#{@openai_base}/v1/some/resource")
      .to_return(status: 200, body: '{"deleted":true}')

    delete proxy_openai_url(path: "v1/some/resource"), headers: auth_headers

    assert_response :success
  end

  test "preserves query parameters" do
    stub_request(:get, "#{@openai_base}/v1/models")
      .with(query: { "limit" => "5", "order" => "desc" })
      .to_return(status: 200, body: '{"data":[]}')

    get proxy_openai_url(path: "v1/models"), params: { limit: 5, order: "desc" }, headers: auth_headers

    assert_response :success
  end

  test "returns upstream 401 error as-is" do
    stub_request(:get, "#{@openai_base}/v1/models")
      .to_return(status: 401, body: '{"error":"unauthorized"}')

    get proxy_openai_url(path: "v1/models"), headers: auth_headers

    assert_response :unauthorized
  end

  test "returns upstream 500 error as-is" do
    stub_request(:get, "#{@openai_base}/v1/models")
      .to_return(status: 500, body: '{"error":"internal server error"}')

    get proxy_openai_url(path: "v1/models"), headers: auth_headers

    assert_response :internal_server_error
  end
end
