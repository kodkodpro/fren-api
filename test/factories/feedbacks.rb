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
FactoryBot.define do
  factory :feedback do
    user
    email { Faker::Internet.email }
    message { Faker::Lorem.sentence(word_count: 10) }
    source { Feedback::IOS_APP_SOURCE }
  end
end
