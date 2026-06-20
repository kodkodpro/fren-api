# typed: true
# frozen_string_literal: true

class ActionDispatch::IntegrationTest
  # Includes
  include Memery

  private

  memoize def test_user
    create(:user)
  end

  def auth_headers(user = nil)
    id = user ? user.id : test_user.id
    { "X-User-Id" => id }
  end

  # Headers for requests through ProxyController. Provisions an active,
  # fresh subscription for the user/transaction_id pair so the
  # AI access callback passes without hitting Apple.
  def proxy_headers(user = nil, transaction_id: "tx-#{SecureRandom.hex(6)}")
    user ||= test_user
    create(:subscription, :active, user:, transaction_id:)
    auth_headers(user).merge("X-iOS-Transaction-Id" => transaction_id)
  end

  memoize def response_json
    JSON.parse(response.body)
  end
end
