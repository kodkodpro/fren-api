# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_05_30_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"

  create_table "admin_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.text "access_token"
    t.datetime "access_token_expires_at"
    t.text "account_id", null: false
    t.datetime "created_at", null: false
    t.text "id_token"
    t.text "password"
    t.text "provider_id", null: false
    t.text "refresh_token"
    t.datetime "refresh_token_expires_at"
    t.text "scope"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["provider_id", "account_id"], name: "index_admin_accounts_on_provider_id_and_account_id"
    t.index ["user_id"], name: "index_admin_accounts_on_user_id"
  end

  create_table "admin_sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.text "ip_address"
    t.text "token", null: false
    t.datetime "updated_at", null: false
    t.text "user_agent"
    t.uuid "user_id", null: false
    t.index ["token"], name: "index_admin_sessions_on_token", unique: true
    t.index ["user_id"], name: "index_admin_sessions_on_user_id"
  end

  create_table "admin_verifications", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.text "identifier", null: false
    t.datetime "updated_at", null: false
    t.text "value", null: false
    t.index ["identifier"], name: "index_admin_verifications_on_identifier"
  end

  create_table "admins", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.citext "email", null: false
    t.boolean "email_verified", default: false, null: false
    t.text "image"
    t.text "name", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
  end

  create_table "analytics_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "name", limit: 2, null: false
    t.datetime "occurred_at", null: false
    t.jsonb "properties", default: {}
    t.uuid "user_id", null: false
    t.index ["name"], name: "index_analytics_events_on_name"
    t.index ["occurred_at"], name: "index_analytics_events_on_occurred_at"
    t.index ["user_id"], name: "index_analytics_events_on_user_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "email"
    t.text "message", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "paywalls", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.jsonb "data", default: {}, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.integer "weight", default: 0, null: false
    t.index ["active"], name: "index_paywalls_on_active"
    t.check_constraint "weight >= 0", name: "paywalls_weight_non_negative"
  end

  create_table "subscriptions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "data", default: {}, null: false
    t.datetime "refreshed_at", null: false
    t.integer "status", limit: 2, null: false
    t.string "transaction_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["status"], name: "index_subscriptions_on_status"
    t.index ["transaction_id"], name: "index_subscriptions_on_transaction_id", unique: true
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "paywall_id", null: false
    t.index ["paywall_id"], name: "index_users_on_paywall_id"
  end

  add_foreign_key "admin_accounts", "admins", column: "user_id", on_delete: :cascade
  add_foreign_key "admin_sessions", "admins", column: "user_id", on_delete: :cascade
  add_foreign_key "analytics_events", "users"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "subscriptions", "users", on_delete: :cascade
  add_foreign_key "users", "paywalls"
end
