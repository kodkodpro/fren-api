# typed: true
# frozen_string_literal: true

Rails.application.routes.draw do
  # OpenAI
  match "proxy/openai/*path", to: "proxy#openai", via: :all, as: :proxy_openai

  # Analytics
  resources :analytics, only: [:create]

  # Feedback
  resources :feedbacks, only: [:create]

  # Remote Config
  get "remote-config", to: "remote_config#show", as: :remote_config

  # Health
  get "up", to: "health#index", as: :rails_health_check
  get "health/trigger-sentry-error", to: "health#trigger_sentry_error", as: :trigger_sentry_error
  get "health/trigger-sentry-message", to: "health#trigger_sentry_message", as: :trigger_sentry_message

  # Root
  root "home#index"
end
