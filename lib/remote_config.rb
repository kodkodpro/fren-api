# typed: true
# frozen_string_literal: true

module RemoteConfig
  REDIS_KEY = "remote-config"
  BLOCKS = T.let([:block_app, :block_recording].freeze, T::Array[Symbol])

  class << self
    extend T::Sig

    sig { params(name: Symbol, config: T.any(Struct::BlockConfig, T::Hash[Symbol, T.untyped])).void }
    def block(name, config)
      validate_block!(name)
      config = deserialize_block_config(config) if config.is_a?(Hash)

      current = load
      hash = serialize(current)
      hash[name] = serialize_block_config(config)

      save(deserialize(hash))
    end

    sig { params(name: Symbol).void }
    def unblock(name)
      validate_block!(name)

      current = load
      hash = serialize(current)
      hash.delete(name)

      save(deserialize(hash))
    end

    sig { returns(RemoteConfig::Struct) }
    def load
      json = REDIS.get(REDIS_KEY)
      return RemoteConfig::Struct.new unless json

      result = RemoteConfig::Struct.deserialize_from(:json, json)
      raise result.error.message if result.failure?

      result.payload
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def to_h
      result = load.serialize_to(:hash, options: { should_serialize_values: true })
      raise result.error.message if result.failure?

      T.unsafe(result.payload)
    end

    private

    sig { params(config: RemoteConfig::Struct).void }
    def save(config)
      result = config.serialize_to(:json, options: { should_serialize_values: true })
      raise result.error.message if result.failure?

      REDIS.set(REDIS_KEY, result.payload)
    end

    sig { params(config: RemoteConfig::Struct).returns(T::Hash[Symbol, T.untyped]) }
    def serialize(config)
      result = config.serialize_to(:hash, options: { should_serialize_values: true })
      raise result.error.message if result.failure?

      T.unsafe(result.payload)
    end

    sig { params(hash: T::Hash[Symbol, T.untyped]).returns(RemoteConfig::Struct) }
    def deserialize(hash)
      result = RemoteConfig::Struct.deserialize_from(:hash, hash)
      raise result.error.message if result.failure?

      result.payload
    end

    sig { params(config: Struct::BlockConfig).returns(T::Hash[Symbol, T.untyped]) }
    def serialize_block_config(config)
      result = config.serialize_to(:hash, options: { should_serialize_values: true })
      raise result.error.message if result.failure?

      T.unsafe(result.payload)
    end

    sig { params(hash: T::Hash[Symbol, T.untyped]).returns(Struct::BlockConfig) }
    def deserialize_block_config(hash)
      if hash[:button].is_a?(Hash)
        hash = hash.merge(button: Struct::Button.new(**hash[:button]))
      end

      Struct::BlockConfig.new(**T.unsafe(hash))
    end

    sig { params(name: Symbol).void }
    def validate_block!(name)
      raise ArgumentError, "Unknown block: #{name}" unless BLOCKS.include?(name)
    end
  end
end
