# typed: true
# frozen_string_literal: true

class AddFreeMemosAvailableToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :free_memos_available, :integer, null: false, default: 3
    add_check_constraint :users, "free_memos_available >= 0", name: "users_free_memos_available_non_negative"
  end
end
