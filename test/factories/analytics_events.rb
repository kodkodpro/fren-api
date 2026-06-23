# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: analytics_events
#
#  id          :bigint           not null, primary key
#  name        :integer          not null
#  occurred_at :datetime         not null
#  properties  :jsonb
#  tier        :integer          default("unknown"), not null
#  created_at  :datetime         not null
#  user_id     :uuid             not null
#
# Indexes
#
#  index_analytics_events_on_name         (name)
#  index_analytics_events_on_occurred_at  (occurred_at)
#  index_analytics_events_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :analytics_event do
    user
    name { 1 }
    properties { {} }
    tier { Analytics::Tier::Unknown.serialize }
    occurred_at { Time.current }
  end
end
