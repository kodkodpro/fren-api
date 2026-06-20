# typed: true
# frozen_string_literal: true

class FreeMemoQuotaController < ApplicationController
  def show
    render json: quota_json(current_user)
  end

  def consume
    FreeMemoQuota::Consume.run!(user: current_user)

    render json: quota_json(current_user.reload)
  end

  private

  def quota_json(user)
    {
      available: user.free_memos_available,
      can_record: user.free_memos_available.positive?,
    }
  end
end
