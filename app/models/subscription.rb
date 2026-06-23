# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: subscriptions
#
#  id             :uuid             not null, primary key
#  data           :jsonb            not null
#  refreshed_at   :datetime         not null
#  status         :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  transaction_id :string           not null
#  user_id        :uuid             not null
#
# Indexes
#
#  index_subscriptions_on_status          (status)
#  index_subscriptions_on_transaction_id  (transaction_id) UNIQUE
#  index_subscriptions_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id) ON DELETE => cascade
#
class Subscription < ApplicationRecord
  # Associations
  belongs_to :user

  # Enums
  sorbet_enum :status, Subscription::Status

  # Validations
  validates :transaction_id, presence: true, uniqueness: true
  validates :status, presence: true
  validates :refreshed_at, presence: true

  # Apple keeps the user entitled during the grace period after a failed
  # renewal, so treat InGracePeriod as still usable.
  def entitled?
    active? || in_grace_period?
  end
end
