# typed: true
# frozen_string_literal: true

class FeedbacksController < PublicController
  def create
    feedback = Feedback.new(feedback_params)
    feedback.user = optional_current_user

    if feedback.save
      render json: { status: :ok },
             status: :created
    else
      render json: { status: :error, errors: feedback.errors.full_messages },
             status: :unprocessable_content
    end
  end

  private

  def optional_current_user
    user_id = request.headers["X-User-Id"]&.strip
    return nil if user_id.blank?

    current_user
  end

  def feedback_params
    params.expect(feedback: [:email, :message, :source])
  end
end
