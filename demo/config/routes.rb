Rails.application.routes.draw do
  root "posts#index"

  get "posts/:slug", to: "posts#show", as: :post
  get "categories", to: "categories#index", as: :categories
  get "categories/:slug", to: "categories#show", as: :category
  get ":slug", to: "pages#show", as: :page

  namespace :admin do
    resources :posts
    resources :pages
    resources :categories
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
