# typed: strict
# frozen_string_literal: true

class ApplicationController < ActionController::API
  # Includes
  include Memery

  # Callbacks
  before_action :authenticate_user!

  private

  # Getters / Setters
  sig { returns(T.nilable(User)) }
  attr_accessor :current_user

  sig { void }
  def authenticate_user!
    user_id = request.headers["X-User-Id"]&.strip
    raise "X-User-Id header is required" if user_id.blank?

    uuid_regex = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i
    raise "X-User-Id header must be a valid UUID" unless user_id.match?(uuid_regex)

    self.current_user = User.find_or_create_by!(id: user_id)
  end
end
