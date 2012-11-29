class UserController < ApplicationController
	before_filter :require_authentication!

	def edit
		@user = current_user
	end

	def update
		if current_user.email != params[:user][:email]
			if current_user.process_email_update(params[:user][:email])
				redirect_to post_auth_path_or_root_path, notice: "Email address updated!"
			else
				render :edit, notice: "Please enter a valid email address."
			end
		end
	end


	private

	def post_auth_path_or_root_path
		if session[:post_auth_path]
			url = session[:post_auth_path]
			session[:post_auth_path] = nil
		else
			url = root_path
		end

		return url
	end
end
