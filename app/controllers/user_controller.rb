class UserController < ApplicationController
	before_filter :require_authentication!

	def edit
		@user = current_user
	end

	def update
		if current_user.update_attribute(:email, params[:user][:email])
			redirect_to root_url, notice: "Email address added!"
		else
			raise "EmailWasNotUpdated"
		end
	end
end
