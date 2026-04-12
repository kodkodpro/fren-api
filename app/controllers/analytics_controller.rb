# typed: true
# frozen_string_literal: true

class AnalyticsController < ApplicationController
  def create
    result = Analytics::IngestService.call(user: T.must(current_user), events: event_params)

    render json: {
             status: :ok,
             inserted: result.inserted_count,
             errors: result.errors,
           },
           status: :created
  end

  private

  def event_params
    Array(params[:events]).map do |e|
      {
        "name" => e[:name],
        "occurred_at" => e[:occurred_at],
        "properties" => e[:properties]&.permit!.to_h,
      }
    end
  end
end
