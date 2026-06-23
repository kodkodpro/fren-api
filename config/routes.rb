# typed: true
# frozen_string_literal: true

Rails.application.routes.draw do
  # Proxies
  match "proxy/openai/*path", to: "proxy#openai", via: :all, as: :proxy_openai
  match "proxy/elevenlabs/*path", to: "proxy#elevenlabs", via: :all, as: :proxy_elevenlabs

  # Analytics
  resources :analytics, only: [:create]

  # Create alias for analytics to avoid blocking by ad blockers
  post "battle-log", to: "analytics#create", as: :battle_log

  # Feedback
  resources :feedbacks, only: [:create]

  # Remote Config
  get "remote-config", to: "remote_config#show", as: :remote_config

  # Paywall
  get "paywall", to: "paywalls#show", as: :paywall

  # Free AI analysis
  get "free-ai-analysis", to: "free_ai_analysis#show", as: :free_ai_analysis
  post "free-ai-analysis/consume", to: "free_ai_analysis#consume", as: :consume_free_ai_analysis

  # Health
  get "up", to: "health#index", as: :rails_health_check

  # Root
  root "home#index"
end
