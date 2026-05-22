# frozen_string_literal: true

class CreateAdminAuthTables < ActiveRecord::Migration[8.1]
  def change
    enable_extension "citext" unless extension_enabled?("citext")

    create_table :admins, id: :uuid do |t|
      t.text :name, null: false
      t.citext :email, null: false
      t.boolean :email_verified, null: false, default: false
      t.text :image

      t.timestamps
    end

    add_index :admins, :email, unique: true

    create_table :admin_sessions, id: :uuid do |t|
      t.datetime :expires_at, null: false
      t.text :token, null: false
      t.text :ip_address
      t.text :user_agent
      t.uuid :user_id, null: false

      t.timestamps
    end

    add_index :admin_sessions, :token, unique: true
    add_index :admin_sessions, :user_id
    add_foreign_key :admin_sessions, :admins, column: :user_id, on_delete: :cascade

    create_table :admin_accounts, id: :uuid do |t|
      t.text :account_id, null: false
      t.text :provider_id, null: false
      t.uuid :user_id, null: false
      t.text :access_token
      t.text :refresh_token
      t.text :id_token
      t.datetime :access_token_expires_at
      t.datetime :refresh_token_expires_at
      t.text :scope
      t.text :password

      t.timestamps
    end

    add_index :admin_accounts, :user_id
    add_index :admin_accounts, [:provider_id, :account_id]
    add_foreign_key :admin_accounts, :admins, column: :user_id, on_delete: :cascade

    create_table :admin_verifications, id: :uuid do |t|
      t.text :identifier, null: false
      t.text :value, null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end

    add_index :admin_verifications, :identifier
  end
end
