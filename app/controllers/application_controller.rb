class ApplicationController < ActionController::Base
	protect_from_forgery

	helper_method :current_user
	helper_method :user_signed_in?
	helper_method :require_authentication!

	rescue_from CanCan::AccessDenied, :with => :render_forbidden

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

	def render_forbidden(exception)
		if user_signed_in?
			render :template => "public/403.html", :status => 403
		else
			session[:post_auth_path] = request.env['PATH_INFO']
			redirect_to "/auth/twitter"
		end
	end
end
