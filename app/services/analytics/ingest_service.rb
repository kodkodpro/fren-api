# typed: true
# frozen_string_literal: true

class Analytics::IngestService
  Result = ::Struct.new(:inserted_count, :errors)

  sig { params(user: User, events: T::Array[T::Hash[String, T.untyped]]).returns(Result) }
  def self.call(user:, events:)
    rows = []
    errors = []
    now = Time.current

    events.each_with_index do |event_hash, index|
      name = event_hash["name"]
      raw_properties = event_hash["properties"] || {}
      properties = raw_properties.respond_to?(:to_unsafe_h) ? raw_properties.to_unsafe_h : raw_properties.to_h
      occurred_at = event_hash["occurred_at"]

      # Validate event name
      enum_value = begin
        Analytics::EventName.deserialize(name)
      rescue KeyError
        errors << { index:, name:, error: "unknown event name" }
        next
      end

      # Validate occurred_at
      timestamp = begin
        Time.zone.parse(occurred_at.to_s)
      rescue ArgumentError, TypeError
        errors << { index:, name:, error: "invalid or missing occurred_at" }
        next
      end

      # Validate properties against schema
      struct_class = Analytics::Properties::SCHEMAS[enum_value]

      begin
        T.must(struct_class).new(**properties.to_h.symbolize_keys)
      rescue ArgumentError, TypeError => e
        errors << { index:, name:, error: "invalid properties: #{e.message}" }
        next
      end

      rows << {
        user_id: user.id,
        name:,
        properties:,
        occurred_at: timestamp,
        created_at: now,
      }
    end

    AnalyticsEvent.insert_all(rows) if rows.any? # rubocop:disable Rails/SkipsModelValidations

    Result.new(inserted_count: rows.size, errors:)
  end
end
