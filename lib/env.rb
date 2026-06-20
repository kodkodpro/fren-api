# typed: true
# frozen_string_literal: true

require "sorbet-runtime"
require "dotenv/load"

class EnvConfig < T::Struct
  const :enable_billing, T::Boolean, default: false
  const :disable_free_memos_quota, T::Boolean, default: false

  const :redis_url, T.nilable(String)

  const :openai_api_url, String
  const :openai_api_key, String

  const :elevenlabs_api_url, String
  const :elevenlabs_api_key, String

  const :sentry_dsn, T.nilable(String)
  const :sentry_environment, T.nilable(String)

  const :app_store_key_id, String
  const :app_store_issuer_id, String
  const :app_store_bundle_id, String
  const :app_store_p8_key, String
  const :app_store_environment, String

  sig { returns(String) }
  def app_store_p8_pem
    app_store_p8_key.gsub('\n', "\n")
  end
end

env_hash = ENV.to_h
  .transform_keys(&:underscore)
  .transform_values(&:strip)

begin
  Env = T.let(
    EnvConfig.deserialize_from!(:hash, env_hash),
    EnvConfig,
  )
rescue StandardError => e
  raise "Environment variables validation failed: #{e.message}"
end
