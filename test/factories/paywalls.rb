# typed: true
# frozen_string_literal: true

# == Schema Information
#
# Table name: paywalls
#
#  id         :uuid             not null, primary key
#  active     :boolean          default(TRUE), not null
#  data       :jsonb            not null
#  name       :string           not null
#  weight     :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_paywalls_on_active  (active)
#
FactoryBot.define do
  factory :paywall do
    name { "Paywall #{SecureRandom.hex(4)}" }
    active { true }
    weight { 1 }

    data do
      {
        locales: {
          "en" => {
            title: "Upgrade",
            bullets: [

              title: "Unlimited access",
              description: "Use every feature without limits.",
              icon: "sparkles",
              icon_color: "#3B82F6",

            ],
          },
        },
        products: [

          apple_product_id: "fren.pro.monthly",

        ],
      }
    end
  end
end
