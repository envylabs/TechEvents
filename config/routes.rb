Techevents::Application.routes.draw do
  resources :events, :except => [:show, :destroy]

  match "/auth/:provider/callback" => "sessions#create", as: :sessions_create
  match "/signout" => "sessions#destroy", :as => :signout

  resource :user, only: [:edit, :update], controller: "user"

  root :to => "home#index"
end
