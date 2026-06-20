# typed: strict
# frozen_string_literal: true

class ApplicationController < ActionController::API
  # Includes
  include Memery

  # Callbacks
  before_action :current_user
  before_action :set_sentry_user

  # Error handling
  rescue_from Fren::AuthError, with: :handle_auth_error
  rescue_from Fren::SubscriptionError, with: :handle_subscription_error

  private

  sig { returns(User) }
  memoize def current_user
    user_id = request.headers["X-User-Id"]&.strip
    raise Fren::AuthenticationFailedError, "X-User-Id header is required" if user_id.blank?

    uuid_regex = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i
    raise Fren::AuthenticationFailedError, "X-User-Id header must be a valid UUID" unless user_id.match?(uuid_regex)

    User.find_or_create_by!(id: user_id)
  end

  sig { void }
  def require_ai_access
    return unless Env.enable_billing
    return if active_subscription?
    return if free_memos_available?

    raise Fren::SubscriptionRequiredError, "Active subscription or free memo quota is required"
  end

  sig { returns(T::Boolean) }
  def free_memos_available?
    return false if Env.disable_free_memos_quota

    current_user.free_memos_available.positive?
  end

  sig { returns(T::Boolean) }
  def active_subscription?
    transaction_id = request.headers["X-iOS-Transaction-Id"]&.strip
    return false if transaction_id.blank?

    result = Subscription::CreateOrRefresh.run!(user_id: current_user.id, transaction_id:)
    result.subscription.entitled?
  rescue AppStoreAPI::Error => e
    Sentry.capture_exception(e, extra: { transaction_id:, user_id: current_user.id })
    raise Fren::SubscriptionVerificationFailedError, "Unable to verify subscription"
  end

  sig { void }
  def set_sentry_user
    Sentry.set_user(id: current_user.id)
  end

  sig { params(error: Fren::AuthError).void }
  def handle_auth_error(error)
    render_fren_error(error, status: :unauthorized)
  end

  sig { params(error: Fren::SubscriptionError).void }
  def handle_subscription_error(error)
    render_fren_error(error, status: :payment_required)
  end

  sig { params(error: Fren::Error, status: Symbol).void }
  def render_fren_error(error, status:)
    render(
      json: {
        status: :error,
        error: {
          message: error.message,
          type: "fren_error",
          code: error.code&.serialize,
        },
      },
      status:,
    )
  end
end
