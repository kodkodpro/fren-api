# typed: true
# frozen_string_literal: true

class User < ApplicationRecord
  # Associations
  belongs_to :paywall
  has_many :analytics_events, dependent: :destroy
  has_many :feedbacks, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  # Validations
  validates :free_ai_analyses_available, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Callbacks
  before_validation :assign_paywall, on: :create

  sig { void }
  def touch_last_request_at_if_stale
    now = Time.current
    rows_updated = self.class
      .where(id:)
      .where("last_request_at IS NULL OR last_request_at < ?", now - 1.minute)
      .update_all(last_request_at: now) # rubocop:disable Rails/SkipsModelValidations -- Keep the stale check atomic.

    return unless rows_updated.positive?

    self.last_request_at = now
    clear_attribute_change(:last_request_at)
  end

  private

  def assign_paywall
    return if paywall_id.present?

    self.paywall = Paywall.pick_for_user!
  end
end
