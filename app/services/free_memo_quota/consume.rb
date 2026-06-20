# typed: true
# frozen_string_literal: true

class FreeMemoQuota::Consume < ApplicationService
  # Arguments
  arg :user, type: User

  # Steps
  step :validate_quota
  step :consume_quota

  private

  def validate_quota
    return if user.free_memos_available.positive?

    raise Fren::FreeMemoQuotaExhaustedError, "Free memo quota exhausted"
  end

  def consume_quota
    user.update!(free_memos_available: user.free_memos_available - 1)
  end
end
