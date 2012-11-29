class Admin::BaseController < ApplicationController
	before_filter :check_admin

	private

	def check_admin
		current_user.admin? ? true : redirect_to(root_url, notice: "You must be an admin to access the admin panel.")
	end
end