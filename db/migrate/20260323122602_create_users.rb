# typed: true
# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid do |t|
      t.datetime :created_at, null: false
    end
  end
end
