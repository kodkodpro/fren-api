# typed: true
# frozen_string_literal: true

class FreeAIAnalysisController < ApplicationController
  def show
    render json: analysis_json(current_user)
  end

  def consume
    FreeAIAnalysis::Consume.run!(user: current_user)

    render json: analysis_json(current_user.reload)
  end

  private

  def analysis_json(user)
    {
      available: user.free_ai_analyses_available,
    }
  end
end
