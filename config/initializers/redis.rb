# typed: strict
# frozen_string_literal: true

REDIS = Redis.new(url: Env.redis_url)
