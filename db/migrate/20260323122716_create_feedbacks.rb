# frozen_string_literal: true

class CreateFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks do |t|
      t.belongs_to :user, type: :uuid, null: false, foreign_key: true

      t.text :email
      t.text :message, null: false

      t.timestamps
    end
  end
end
