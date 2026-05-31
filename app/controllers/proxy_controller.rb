# typed: true
# frozen_string_literal: true

class ProxyController < ApplicationController
  # Callbacks
  before_action :require_active_subscription

  def openai
    proxy(
      base_url: Env.openai_api_url,
      auth_header: ["Authorization", "Bearer #{Env.openai_api_key}"],
      service: "OpenAI",
    )
  end

  def elevenlabs
    proxy(
      base_url: Env.elevenlabs_api_url,
      auth_header: ["xi-api-key", Env.elevenlabs_api_key],
      service: "ElevenLabs",
    )
  end

  private

  def proxy(base_url:, auth_header:, service:)
    uri = build_target_uri(base_url)
    upstream = execute_request(uri, auth_header:)

    notify_sentry(upstream, service:) unless upstream.is_a?(Net::HTTPSuccess)

    render body: upstream.body,
           status: upstream.code.to_i,
           content_type: upstream["Content-Type"]
  end

  def build_target_uri(base_url)
    target = "#{base_url}/#{request.path_parameters[:path]}"
    target += "?#{request.query_string}" if request.query_string.present?
    URI.parse(target)
  end

  def execute_request(uri, auth_header:)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"

    req = net_http_request_class.new(uri)
    name, value = auth_header
    req[name] = value
    req["Content-Type"] = request.headers["Content-Type"] if request.headers["Content-Type"]
    req["Accept"] = request.headers["Accept"] if request.headers["Accept"]
    req.body = request.raw_post if request.post? || request.put? || request.patch?

    http.request(req)
  end

  def notify_sentry(upstream, service:)
    Sentry.capture_message(
      "#{service} Proxy Error",
      level: :error,
      extra: { status: upstream.code.to_i, body: upstream.body, path: request.path },
    )

    Rails.logger.error("[#{service} Proxy] Error #{upstream.code}: #{upstream.body}")
  end

  def net_http_request_class
    case request.method
    when "GET" then Net::HTTP::Get
    when "POST" then Net::HTTP::Post
    when "PUT" then Net::HTTP::Put
    when "PATCH" then Net::HTTP::Patch
    when "DELETE" then Net::HTTP::Delete
    when "HEAD" then Net::HTTP::Head
    when "OPTIONS" then Net::HTTP::Options
    else
      raise ArgumentError, "Unsupported HTTP method: #{request.method}"
    end
  end
end
