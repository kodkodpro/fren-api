# typed: true
# frozen_string_literal: true

module AppStoreAPI
  PRODUCTION_BASE_URL = "https://api.storekit.apple.com"
  SANDBOX_BASE_URL = "https://api.storekit-sandbox.apple.com"
  AUDIENCE = "appstoreconnect-v1"

  class << self
    sig { params(transaction_id: String).returns(AppStoreAPI::StatusResponse) }
    def get_subscription_statuses(transaction_id) # rubocop:disable Rails/Delegate
      Client.get_subscription_statuses(transaction_id)
    end

    sig { returns(String) }
    def base_url
      Env.app_store_environment == "sandbox" ? SANDBOX_BASE_URL : PRODUCTION_BASE_URL
    end
  end
end
