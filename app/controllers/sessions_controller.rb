class SessionsController < ApplicationController
	def create
		user = User.from_omniauth(env['omniauth.auth'])
		session[:user_id] = user.id

		if user.email.blank?
			redirect_to user_initial_setup_url
		else
			redirect_to root_url, notice: "Signed in!"
		end
	end

	def destroy
		session[:user_id] = nil
		redirect_to root_url, :notice => 'Signed out!'
	end
end
