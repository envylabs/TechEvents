class UsersController < ApplicationController
	def initial_setup
		if request.get?
			@user = current_user
			render "users/initial_setup"
		elsif request.post?
			if current_user.update_attribute(:email, params[:user][:email])
				redirect_to root_url, notice: "Email address added!"
			else
				raise "EmailWasNotUpdated"
			end
		end
	end
end
