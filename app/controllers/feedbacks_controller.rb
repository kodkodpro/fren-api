# typed: true
# frozen_string_literal: true

class FeedbacksController < ApplicationController
  def create
    feedback = Feedback.new(feedback_params)
    feedback.user = current_user

    if feedback.save
      render json: { status: :ok },
             status: :created
    else
      render json: { status: :error, errors: feedback.errors.full_messages },
             status: :unprocessable_content
    end
  end

  private

  def feedback_params
    params.expect(feedback: [:email, :message])
  end
end
