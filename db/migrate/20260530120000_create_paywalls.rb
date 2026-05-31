# frozen_string_literal: true

class CreatePaywalls < ActiveRecord::Migration[8.1]
  class PaywallRecord < ActiveRecord::Base
    self.table_name = "paywalls"
  end

  class UserRecord < ActiveRecord::Base
    self.table_name = "users"
  end

  FALLBACK_PAYWALL_NAME = "June 1st, 2026"
  FALLBACK_PAYWALL_DATA = {
    default_locale: "en",
    locales: {
      "en" => {
        title: "Upgrade to Fren Pro",
        bullets: [

          title: "Unlimited conversations",
          description: "Keep using Fren without limits.",
          icon: "message-circle",
          icon_color: "#3B82F6",

        ],
      },
    },
    products: [
      {
        apple_product_id: "fren.pro.monthly",
      },
      {
        apple_product_id: "fren.pro.yearly",
      },
    ],
  }.freeze

  def up
    create_table :paywalls, id: :uuid, default: -> { "gen_random_uuid()" } do |t|
      t.string :name, null: false
      t.jsonb :data, null: false, default: {}
      t.boolean :active, null: false, default: true
      t.integer :weight, null: false, default: 0
      t.timestamps
    end

    add_check_constraint :paywalls, "weight >= 0", name: "paywalls_weight_non_negative"
    add_index :paywalls, :active

    PaywallRecord.reset_column_information

    fallback_paywall = PaywallRecord.create!(
      name: FALLBACK_PAYWALL_NAME,
      data: FALLBACK_PAYWALL_DATA,
      active: true,
      weight: 1,
    )

    add_reference :users, :paywall, type: :uuid, foreign_key: true

    UserRecord.reset_column_information
    UserRecord.update_all(paywall_id: fallback_paywall.id) # rubocop:disable Rails/SkipsModelValidations

    change_column_null :users, :paywall_id, false
  end

  def down
    remove_reference :users, :paywall, type: :uuid, foreign_key: true
    drop_table :paywalls
  end
end
