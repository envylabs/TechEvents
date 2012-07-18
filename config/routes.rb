Techevents::Application.routes.draw do
  resources :events, :except => [:show, :destroy]

  match "/auth/:provider/callback" => "sessions#create"
  match "/signout" => "sessions#destroy", :as => :signout

  match "/users/initial_setup" => "users#initial_setup", :as => :user_initial_setup, :via => [:get, :post]

  root :to => "home#index"
end
