# typed: true
# frozen_string_literal: true

class Feedback < ApplicationRecord
  # Associations
  belongs_to :user

  # Validations
  validates :message, length: { minimum: 10 }, presence: true
end
