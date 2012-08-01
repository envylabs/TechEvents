class UserController < ApplicationController
	before_filter :require_authentication!

	def edit
		@user = current_user
	end

	def update
		if session[:post_auth_path]
			url = session[:post_auth_path]
			session[:post_auth_path] = nil
		else
			url = root_path
		end

		if current_user.update_attribute(:email, params[:user][:email])
			redirect_to url, notice: "Email address updated!"
		else
			raise "EmailWasNotUpdated"
		end
	end
end
