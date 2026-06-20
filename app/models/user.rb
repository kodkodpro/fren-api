# typed: true
# frozen_string_literal: true

class User < ApplicationRecord
  # Associations
  belongs_to :paywall
  has_many :analytics_events, dependent: :destroy
  has_many :feedbacks, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  # Validations
  validates :free_memos_available, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Callbacks
  before_validation :assign_paywall, on: :create

  private

  def assign_paywall
    return if paywall_id.present?

    self.paywall = Paywall.pick_for_user!
  end
end
