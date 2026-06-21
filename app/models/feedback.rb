# typed: true
# frozen_string_literal: true

class Feedback < ApplicationRecord
  # Constants
  IOS_APP_SOURCE = "ios-app"
  WEB_CONTACT_SOURCE = "web-contact"
  SOURCES = [
    IOS_APP_SOURCE,
    WEB_CONTACT_SOURCE,
  ].freeze

  # Associations
  belongs_to :user, optional: true

  # Validations
  validates :message, length: { minimum: 10 }, presence: true
  validates :source, presence: true, inclusion: { in: SOURCES }
  validate :user_required_for_ios_app

  private

  def user_required_for_ios_app
    return unless source == IOS_APP_SOURCE
    return if user.present?

    errors.add(:user, "must exist")
  end
end
