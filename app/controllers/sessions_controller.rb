class SessionsController < ApplicationController
	def create
		user = User.from_omniauth(env['omniauth.auth'])
		session[:user_id] = user.id

		if user.email.blank?
			url = edit_user_path
		elsif session[:post_auth_path] 
			url = session[:post_auth_path]
			session[:post_auth_path] = nil
		else
			url = root_path
		end

		redirect_to url, notice: "Signed in!"
	end

	def destroy
		session[:user_id] = nil
		redirect_to root_url, :notice => 'Signed out!'
	end
end
