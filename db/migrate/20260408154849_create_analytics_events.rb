# frozen_string_literal: true

class CreateAnalyticsEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :analytics_events do |t|
      t.belongs_to :user, type: :uuid, null: false, foreign_key: true
      t.integer :name, null: false, limit: 2
      t.jsonb :properties, default: {}
      t.datetime :occurred_at, null: false
      t.datetime :created_at, null: false
    end

    add_index :analytics_events, :name
    add_index :analytics_events, :occurred_at
  end
end
