# typed: true
# frozen_string_literal: true

class AnalyticsEvent < ApplicationRecord
  # Associations
  belongs_to :user

  # Enums
  sorbet_enum :tier, Analytics::Tier

  # Validations
  validates :name, presence: true, inclusion: { in: Analytics::EventName.serialized_values }
  validates :tier, presence: true, inclusion: { in: Analytics::Tier.values }
  validates :occurred_at, presence: true
end
