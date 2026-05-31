# typed: true
# frozen_string_literal: true

class Paywall < ApplicationRecord
  # Associations
  has_many :users, dependent: :restrict_with_exception

  # Attributes
  T.unsafe(self).sorbet_attributes :data, Paywall::Data

  # Scopes
  scope :active_assignable, -> { where(active: true).where("weight > 0") }

  # Validations
  validates :name, presence: true
  validates :active, inclusion: { in: [true, false] }
  validates :weight, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validate :data_includes_english_locale
  validate :data_includes_default_locale

  sig { params(random: T.nilable(Random)).returns(Paywall) }
  def self.pick_for_user!(random: nil)
    paywalls = active_assignable.to_a
    total_weight = paywalls.sum(&:weight)

    raise ActiveRecord::RecordNotFound, "No active paywalls with positive weight" unless total_weight.positive?

    threshold = random ? random.rand(total_weight) : rand(total_weight)
    cumulative_weight = 0

    paywalls.each do |paywall|
      cumulative_weight += paywall.weight
      return paywall if threshold < cumulative_weight
    end

    T.must(paywalls.last)
  end

  sig { params(device_language: T.nilable(String)).returns(Paywall::Data::Content) }
  def localized_content(device_language) # rubocop:disable Rails/Delegate -- Using `delegate` crashes code
    data.localized_content(device_language)
  end

  private

  sig { void }
  def data_includes_english_locale
    return if data.locale_available?("en")

    errors.add(:data, "must include an en locale")
  end

  sig { void }
  def data_includes_default_locale
    return if data.locale_available?(data.default_locale)

    errors.add(:data, "must include the default locale")
  end
end
