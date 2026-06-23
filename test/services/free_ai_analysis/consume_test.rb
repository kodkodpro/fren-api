# typed: true
# frozen_string_literal: true

require "test_helper"

class FreeAIAnalysis::ConsumeTest < ActiveSupport::TestCase
  test "decrements available free AI analyses" do
    user = create(:user, free_ai_analyses_available: 2)

    assert_difference -> { user.reload.free_ai_analyses_available }, -1 do
      FreeAIAnalysis::Consume.run!(user:)
    end
  end

  test "raises when free AI analysis is exhausted" do
    user = create(:user, free_ai_analyses_available: 0)

    assert_no_difference -> { user.reload.free_ai_analyses_available } do
      assert_raises(Fren::FreeAIAnalysisExhaustedError) do
        FreeAIAnalysis::Consume.run!(user:)
      end
    end
  end

  test "consumes the final free AI analysis once" do
    user = create(:user, free_ai_analyses_available: 1)

    FreeAIAnalysis::Consume.run!(user:)

    assert_equal 0, user.reload.free_ai_analyses_available

    assert_no_difference -> { user.reload.free_ai_analyses_available } do
      assert_raises(Fren::FreeAIAnalysisExhaustedError) do
        FreeAIAnalysis::Consume.run!(user:)
      end
    end
  end
end
