# typed: true
# frozen_string_literal: true

class User < ApplicationRecord
  # Associations
  belongs_to :paywall
  has_many :analytics_events, dependent: :destroy
  has_many :feedbacks, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  # Callbacks
  before_validation :assign_paywall, on: :create

  private

  def assign_paywall
    return if paywall_id.present?

    self.paywall = Paywall.pick_for_user!
  end
end
