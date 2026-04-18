# typed: true
# frozen_string_literal: true

class HealthController < PublicController
  def index
    render plain: "We're good! Don't worry 😉"
  end
end
