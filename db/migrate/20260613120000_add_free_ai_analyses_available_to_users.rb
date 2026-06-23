# typed: true
# frozen_string_literal: true

class AddFreeAIAnalysesAvailableToUsers < ActiveRecord::Migration[8.1]
  CONSTRAINT_NAME = "users_free_ai_analyses_available_non_negative"

  def up
    change_table :users, bulk: true do |t|
      t.remove :free_memos_available, type: :integer, null: false, default: 3
      t.integer :free_ai_analyses_available, null: false, default: 3
    end

    add_check_constraint :users, "free_ai_analyses_available >= 0", name: CONSTRAINT_NAME, if_not_exists: true
  end

  def down
    change_table :users, bulk: true do |t|
      if t.column_exists?(:free_ai_analyses_available)
        t.remove :free_ai_analyses_available, type: :integer, null: false, default: 3
      end

      unless t.column_exists?(:free_memos_available)
        t.integer :free_memos_available, null: false, default: 3
      end
    end
  end
end
