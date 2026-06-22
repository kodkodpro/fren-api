# frozen_string_literal: true

class AddTierToAnalyticsEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :analytics_events, :tier, :integer, limit: 2, null: false, default: 0
  end
end
