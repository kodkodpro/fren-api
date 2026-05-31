# typed: true
# frozen_string_literal: true

FactoryBot.define do
  factory :paywall do
    name { "Paywall #{SecureRandom.hex(4)}" }
    active { true }
    weight { 1 }

    data do
      {
        default_locale: "en",
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
