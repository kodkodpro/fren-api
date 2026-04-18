# typed: true
# frozen_string_literal: true

module RemoteConfig
  CACHE_KEY = "remote-config"
  BLOCKS = T.let([:block_app, :block_recording].freeze, T::Array[Symbol])
  SETTINGS = T.let([:transcription_provider].freeze, T::Array[Symbol])

  class << self
    # Delegates
    delegate :to_h, to: :load

    sig { params(name: Symbol, config: T.any(Struct::BlockConfig, T::Hash[Symbol, T.untyped])).void }
    def block(name, config)
      validate_block!(name)
      config = Struct::BlockConfig.deserialize_from!(:hash, config) if config.is_a?(Hash)

      hash = load.to_h
      hash[name] = config.to_h

      save(RemoteConfig::Struct.deserialize_from!(:hash, hash))
    end

    sig { params(name: Symbol).void }
    def unblock(name)
      validate_block!(name)

      hash = load.to_h
      hash.delete(name)

      save(RemoteConfig::Struct.deserialize_from!(:hash, hash))
    end

    sig { params(name: Symbol, value: T.any(T::Enum, String)).void }
    def set(name, value)
      validate_setting!(name)

      hash = load.to_h
      hash[name] = value.is_a?(T::Enum) ? value.serialize : value

      save(RemoteConfig::Struct.deserialize_from!(:hash, hash))
    end

    sig { params(name: Symbol).void }
    def unset(name)
      validate_setting!(name)

      hash = load.to_h
      hash.delete(name)

      save(RemoteConfig::Struct.deserialize_from!(:hash, hash))
    end

    sig { returns(RemoteConfig::Struct) }
    def load
      json = Rails.cache.read(CACHE_KEY)
      return RemoteConfig::Struct.new unless json

      RemoteConfig::Struct.deserialize_from!(:json, json)
    end

    sig { void }
    def reset!
      Rails.cache.delete(CACHE_KEY)
    end

    private

    sig { params(config: RemoteConfig::Struct).void }
    def save(config)
      json = config.serialize_to!(:json, options: { should_serialize_values: true })
      Rails.cache.write(CACHE_KEY, json)
    end

    sig { params(name: Symbol).void }
    def validate_block!(name)
      raise ArgumentError, "Unknown block: #{name}" unless BLOCKS.include?(name)
    end

    sig { params(name: Symbol).void }
    def validate_setting!(name)
      raise ArgumentError, "Unknown setting: #{name}" unless SETTINGS.include?(name)
    end
  end
end
