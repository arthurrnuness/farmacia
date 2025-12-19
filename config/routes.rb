require 'sidekiq/web'
Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  # Landing page
  root 'landing#index'

  # Settings routes
  get 'settings', to: 'settings#index', as: 'settings'
  get 'settings/export', to: 'settings#export', as: 'settings_export'
  post 'settings/import', to: 'settings#import', as: 'settings_import'

  # Review routes
  get 'review', to: 'settings#review_page', as: 'review'
  get 'review/data', to: 'settings#review', as: 'review_data'

  resources :habitos do
    member do
      get 'progresso'
      get 'estatisticas'
    end
  end
  resources :registros, only: [:new, :create, :edit, :update]

  get 'dashboard', to: 'dashboard#index'
  get 'dashboard/grid', to: 'dashboard#grid'

  post 'registros/toggle', to: 'registros#toggle'
  post 'registros/editar_ou_criar', to: 'registros#editar_ou_criar'

  # Payment routes
  get 'pricing', to: 'payments#pricing', as: 'pricing'
  post 'payments/checkout', to: 'payments#checkout', as: 'payments_checkout'
  get 'payments/success', to: 'payments#success', as: 'payments_success'
  get 'payments/cancel', to: 'payments#cancel', as: 'payments_cancel'
  get 'payments/portal', to: 'payments#portal', as: 'payments_portal'

  # Webhook routes
  post 'webhooks/stripe', to: 'webhooks#stripe'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  
  mount Sidekiq::Web => '/sidekiq'

  get 'calendario', to: 'dashboard#calendario'

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
