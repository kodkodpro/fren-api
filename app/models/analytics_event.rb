# typed: true
# frozen_string_literal: true

class AnalyticsEvent < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :name, presence: true, inclusion: { in: Analytics::EventName.serialized_values }
  validates :occurred_at, presence: true
end
