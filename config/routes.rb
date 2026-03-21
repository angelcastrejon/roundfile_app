Rails.application.routes.draw do
  root "pages#home"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Authentication
  get "sign_up", to: "users#new", as: :sign_up
  get "sign_in", to: "sessions#new", as: :sign_in
  delete "sign_out", to: "sessions#destroy", as: :sign_out
  resource :session, only: [:create]

  # Users
  resources :users

  # Resumes with nested comments, ratings, and sections
  resources :resumes do
    resources :comments, only: [:create, :edit, :update, :destroy]
    resources :ratings, only: [:create, :update, :destroy]
    resources :resume_sections, only: [:create, :update, :destroy]
  end

  # Standalone sections (user's reusable content library)
  resources :sections, except: [:index]

  # Custom collection routes
  get "my/resumes", to: "resumes#my_resumes", as: :my_resumes
  get "my/sections", to: "sections#my_sections", as: :my_sections
  get "browse/resumes", to: "resumes#user_resumes", as: :user_resumes
end
