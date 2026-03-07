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
    resources :plans
    resources :subscriptions, only: %i[index show new create] do
      member do
        patch :activate
        patch :fail
        patch :retry
        patch :cancel
        patch :close
      end
    end
    root to: "dashboard#index"
  end

  namespace :customer do
    resources :subscriptions, only: %i[index new create] do
      member do
        patch :cancel
      end
    end
    resource :profile, only: %i[show edit update]
    root to: "dashboard#index"
  end
end
