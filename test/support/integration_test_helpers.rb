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

  memoize def response_json
    JSON.parse(response.body)
  end
end
