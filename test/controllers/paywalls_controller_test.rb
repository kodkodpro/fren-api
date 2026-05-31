# typed: true
# frozen_string_literal: true

require "test_helper"

class PaywallsControllerTest < ActionDispatch::IntegrationTest
  test "returns assigned paywall" do
    paywall = create(:paywall)
    user = create(:user, paywall:)

    get paywall_url, headers: auth_headers(user)

    assert_response :success
    assert_equal paywall.id, response_json["id"]
    assert_equal paywall.name, response_json["name"]
    assert_equal "Upgrade", response_json["title"]
    assert_equal "Unlimited access", response_json.dig("bullets", 0, "title")
    assert_equal "fren.pro.monthly", response_json.dig("products", 0, "apple_product_id")
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
    user = create(:user, paywall:)

    get paywall_url, headers: auth_headers(user).merge("X-Device-Language" => "pt-BR")

    assert_response :success
    assert_equal "Assinar", response_json["title"]
  end

  test "falls back to base language" do
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
    user = create(:user, paywall:)

    get paywall_url, headers: auth_headers(user).merge("X-Device-Language" => "pt-BR")

    assert_response :success
    assert_equal "Assinar", response_json["title"]
  end

  test "falls back to english when language is missing or unsupported" do
    paywall = create(:paywall)
    user = create(:user, paywall:)

    get paywall_url, headers: auth_headers(user).merge("X-Device-Language" => "fr-FR")

    assert_response :success
    assert_equal "Upgrade", response_json["title"]
  end

  test "requires authentication" do
    get paywall_url

    assert_response :unauthorized
    assert_equal "X-User-Id header is required", response_json["error"]
  end
end
