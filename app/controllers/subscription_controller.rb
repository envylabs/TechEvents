class SubscriptionController < ApplicationController
  # POST /subscription
  # POST /subscription.json
  def create
  	subscription = Gibbon.listSubscribe({ id: ENV['MC_LIST_ID'], email_address: params[:subscription][:email], double_optin: false })

  	if subscription == true
  		puts "New subscription"
  		cookies[:user_subscribed] = "true"
  	elsif subscription.class == Hash
  		puts "Errors returned"
  		# @error = subscription['error']
  		@error = "You're already subscribed to the newsletter!"
  	else
  		puts "What happened?"
  	end
  end
end
