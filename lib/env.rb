# typed: true
# frozen_string_literal: true

require "sorbet-runtime"
require "dotenv/load"

class EnvConfig < T::Struct
  const :dashboard_username, String
  const :dashboard_password, String

  const :redis_url, T.nilable(String)
  const :openai_api_url, String
  const :openai_api_key, String
  const :elevenlabs_api_url, String
  const :elevenlabs_api_key, String
  const :sentry_dsn, T.nilable(String)
  const :sentry_environment, T.nilable(String)
end

env_hash = ENV.to_h.transform_keys(&:underscore)

begin
  Env = T.let(
    EnvConfig.deserialize_from!(:hash, env_hash),
    EnvConfig,
  )
rescue StandardError => e
  if ENV["SECRET_KEY_BASE_DUMMY"] != "1"
    raise "Environment variables validation failed: #{e.message}"
  end
end
