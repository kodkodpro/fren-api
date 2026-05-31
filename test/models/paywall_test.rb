# typed: true
# frozen_string_literal: true

require "test_helper"

class PaywallTest < ActiveSupport::TestCase
  test "validates weight is non-negative" do
    paywall = build(:paywall, weight: -1)

    assert_not paywall.valid?
    assert_includes paywall.errors[:weight], "must be greater than or equal to 0"
  end

  test "validates data includes english locale" do
    paywall = build(
      :paywall,
      data: {
        default_locale: "pt",
        locales: {
          "pt" => {
            title: "Atualizar",
            bullets: [],
          },
        },
        products: [],
      },
    )

    assert_not paywall.valid?
    assert_includes paywall.errors[:data], "must include an en locale"
  end

  test "serializes data as typed struct" do
    paywall = create(:paywall)

    assert_instance_of Paywall::Data, paywall.reload.data
    assert_equal "Upgrade", paywall.data.locales.fetch("en").title
    assert_equal "fren.pro.monthly", paywall.data.products.first.apple_product_id
  end

  test "returns exact locale content" do
    paywall = create(
      :paywall,
      data: {
        default_locale: "en",
        locales: {
          "en" => { title: "Upgrade", bullets: [] },
          "pt-BR" => { title: "Assinar", bullets: [] },
        },
        products: [],
      },
    )

    assert_equal "Assinar", paywall.localized_content("pt-BR").title
  end

  test "falls back to base locale" do
    paywall = create(
      :paywall,
      data: {
        default_locale: "en",
        locales: {
          "en" => { title: "Upgrade", bullets: [] },
          "pt" => { title: "Assinar", bullets: [] },
        },
        products: [],
      },
    )

    assert_equal "Assinar", paywall.localized_content("pt-BR").title
  end

  test "falls back to english locale" do
    paywall = create(:paywall)

    assert_equal "Upgrade", paywall.localized_content("fr-FR").title
  end

  test "picks active paywall by positive weight" do
    create(:paywall, active: false, weight: 100)
    create(:paywall, active: true, weight: 0)
    assignable = create(:paywall, active: true, weight: 1)

    assert_equal assignable, Paywall.pick_for_user!
  end

  test "raises when there are no active paywalls with positive weight" do
    create(:paywall, active: true, weight: 0)
    create(:paywall, active: false, weight: 1)

    assert_raises(ActiveRecord::RecordNotFound) { Paywall.pick_for_user! }
  end
end
