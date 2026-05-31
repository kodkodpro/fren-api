# typed: true
# frozen_string_literal: true

class PaywallsController < ApplicationController
  def show
    paywall = current_user.paywall
    content = paywall.localized_content(request.headers["X-Device-Language"])

    render json: {
      id: paywall.id,
      name: paywall.name,
      title: content.title,
      bullets: content.bullets.map(&:to_h),
      products: paywall.data.products.map(&:to_h),
    }
  end
end
