# typed: true
# frozen_string_literal: true

Rails.application.routes.draw do
  # Proxies
  match "proxy/openai/*path", to: "proxy#openai", via: :all, as: :proxy_openai
  match "proxy/elevenlabs/*path", to: "proxy#elevenlabs", via: :all, as: :proxy_elevenlabs

  # Analytics
  resources :analytics, only: [:create]

  # Feedback
  resources :feedbacks, only: [:create]

  # Remote Config
  get "remote-config", to: "remote_config#show", as: :remote_config

  # Paywall
  get "paywall", to: "paywalls#show", as: :paywall

  # Free memo quota
  get "free-memo-quota", to: "free_memo_quota#show", as: :free_memo_quota
  post "free-memo-quota/consume", to: "free_memo_quota#consume", as: :consume_free_memo_quota

  # Health
  get "up", to: "health#index", as: :rails_health_check

  # Root
  root "home#index"
end
