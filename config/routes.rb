Techevents::Application.routes.draw do
	resources :events, :except => [:show, :destroy]
	match "/groups/:id/last_event" => "groups#last_event", format: :json

	match "/auth/:provider/callback" => "sessions#create", as: :sessions_create
	match "/signout" => "sessions#destroy", :as => :signout

	resource :user, only: [:edit, :update], controller: "user"
	resource :subscription, only: [:create, :destroy], controller: "subscription"

	root :to => "events#index"

	if Rails.env.development?
		match "/delayed_job" => DelayedJobWeb, :anchor => false
	end

	match "/home/index" => "home#index"
end
