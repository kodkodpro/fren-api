# frozen_string_literal: true

class AddSourceToFeedbacks < ActiveRecord::Migration[8.1]
  def change
    change_table :feedbacks, bulk: true do |t|
      t.change_null :user_id, true
      t.string :source, null: false, default: "ios-app"
    end
  end
end
