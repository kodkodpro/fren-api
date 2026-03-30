# typed: true
# frozen_string_literal: true

class RemoteConfigController < PublicController
  def show
    render json: RemoteConfig.to_h
  end
end
