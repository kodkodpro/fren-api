# typed: true
# frozen_string_literal: true

class FreeAIAnalysis::Consume < ApplicationService
  # Arguments
  arg :user, type: User

  # Steps
  step :validate_analysis
  step :consume_analysis

  private

  def validate_analysis
    raise Fren::FreeAIAnalysisExhaustedError, "Free AI analysis exhausted" if Env.disable_free_ai_analysis
    return if user.free_ai_analyses_available.positive?

    raise Fren::FreeAIAnalysisExhaustedError, "Free AI analysis exhausted"
  end

  def consume_analysis
    user.update!(free_ai_analyses_available: user.free_ai_analyses_available - 1)
  end
end
