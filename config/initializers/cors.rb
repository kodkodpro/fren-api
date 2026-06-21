# typed: true
# frozen_string_literal: true

class FeedbackCors
  ALLOWED_ORIGINS = [
    "https://fren.day",
    "https://www.fren.day",
    "http://localhost:4321",
    "http://127.0.0.1:4321",
  ].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    origin = request.get_header("HTTP_ORIGIN")

    if request.options? && request.path == "/feedbacks" && allowed_origin?(origin)
      return [
        204,
        cors_headers(origin).merge("Content-Length" => "0"),
        [],
      ]
    end

    status, headers, response = @app.call(env)
    headers = headers.merge(cors_headers(origin)) if request.path == "/feedbacks" && allowed_origin?(origin)

    [
      status,
      headers,
      response,
    ]
  end

  private

  def allowed_origin?(origin)
    ALLOWED_ORIGINS.include?(origin)
  end

  def cors_headers(origin)
    {
      "Access-Control-Allow-Origin" => origin,
      "Access-Control-Allow-Methods" => "POST, OPTIONS",
      "Access-Control-Allow-Headers" => "Content-Type",
      "Access-Control-Max-Age" => "7200",
      "Vary" => "Origin",
    }
  end
end

Rails.application.config.middleware.insert_before 0, FeedbackCors
