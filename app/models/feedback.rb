# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: feedbacks
#
#  id         :bigint           not null, primary key
#  email      :text
#  message    :text             not null
#  source     :string           default("ios-app"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :uuid
#
# Indexes
#
#  index_feedbacks_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
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
