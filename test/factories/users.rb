# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                         :uuid             not null, primary key
#  free_ai_analyses_available :integer          default(3), not null
#  last_request_at            :datetime
#  created_at                 :datetime         not null
#  paywall_id                 :uuid             not null
#
# Indexes
#
#  index_users_on_paywall_id  (paywall_id)
#
# Foreign Keys
#
#  fk_rails_...  (paywall_id => paywalls.id)
#
FactoryBot.define do
  factory :user do
    id { SecureRandom.uuid }

    before(:create) do
      create(:paywall) unless Paywall.active_assignable.exists?
    end
  end
end
