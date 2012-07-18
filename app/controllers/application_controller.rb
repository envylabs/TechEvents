class ApplicationController < ActionController::Base
	protect_from_forgery

	helper_method :current_user
	helper_method :user_signed_in?
	helper_method :require_authentication!

	private

	def current_user
		@current_user ||= User.find(session[:user_id]) if session[:user_id]
	end

	def user_signed_in?
		!!current_user
	end

	def require_authentication!
		if !user_signed_in?
			redirect_to "/auth/twitter"
		end
	end
end
