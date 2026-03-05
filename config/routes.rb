Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "registrations",
    sessions: "sessions"
  }

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  root to: "home#index"

  # Área do administrador
  namespace :admin do
    resources :users do
      member do
        patch :update_role
      end
    end
    # Futuros: plans, subscriptions, billing_reports
    root to: "dashboard#index"
  end
end
