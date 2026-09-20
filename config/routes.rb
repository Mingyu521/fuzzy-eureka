Rails.application.routes.draw do
  root "projects#index"

  resources :projects, only: [ :create, :destroy ] do
    member do
      get :feed
      get :charts
      get :insight
      get :playground
      get :settings
    end
  end

  namespace :api do
    resources :projects, only: [ :create ]

    resources :events, only: [ :index, :create ] do
      member do
        post :favorite
        post :delete
      end
    end

    post "insight", to: "insights#create"
    get "charts", to: "charts#show"
  end

  get "up" => "rails/health#show", as: :rails_health_check

  mount ActionCable.server => "/cable"
end
