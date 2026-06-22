# typed: true
# frozen_string_literal: true

class Analytics::Ingest < ApplicationService
  # Arguments
  arg :user, type: User
  arg :events, type: Array

  private

  def run
    created_at = Time.current

    rows = []
    event_errors = []

    events.each_with_index do |event_hash, index|
      name = event_hash["name"]
      properties = event_hash["properties"] || {}

      enum_value = begin
        Analytics::EventName.deserialize(name)
      rescue KeyError
        event_errors << { index:, name:, error: "unknown event name" }
        nil
      end

      if enum_value
        begin
          enum_value.properties_schema.new(**properties.symbolize_keys)
        rescue ArgumentError, TypeError => e
          event_errors << { index:, name:, error: "invalid properties: #{e.message}" }
        end
      end

      tier = begin
        Analytics::Tier.deserialize_payload(event_hash["tier"])
      rescue KeyError
        event_errors << { index:, name:, error: "invalid tier" }
        Analytics::Tier::Unknown
      end

      occurred_at = begin
        parsed_at = Time.zone.parse(event_hash["occurred_at"].to_s)
        raise ArgumentError if parsed_at.nil?

        parsed_at
      rescue ArgumentError, TypeError
        event_errors << { index:, name:, error: "invalid or missing occurred_at" }
        created_at
      end

      rows << {
        user_id: user.id,
        name:,
        properties:,
        tier: tier.serialize,
        occurred_at:,
        created_at:,
      }
    end

    AnalyticsEvent.insert_all(rows, returning: false) if rows.any? # rubocop:disable Rails/SkipsModelValidations

    return if event_errors.empty?

    Rails.logger.warn("Invalid analytics events received: #{event_errors.inspect} (user_id: #{user.id})")

    Sentry.capture_message(
      "Invalid analytics events received",
      level: :warning,
      extra: { errors: event_errors, user_id: user.id },
    )
  end
end
