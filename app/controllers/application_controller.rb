class ApplicationController < ActionController::Base
	protect_from_forgery

	helper_method :current_user
	helper_method :user_signed_in?
	helper_method :admin_signed_in?
	helper_method :require_authentication!
	helper_method :sanitize_filename

	rescue_from CanCan::AccessDenied, :with => :render_forbidden

	before_filter :set_locale

	private

	def current_user
		@current_user ||= User.find(session[:user_id]) if session[:user_id]
	end

	def user_signed_in?
		!!current_user
	end

	def admin_signed_in?
		!!current_user && !!current_user.admin?
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

	# Thanks to http://stackoverflow.com/a/10823131/483418
	def sanitize_filename(filename)
	  # Split the name when finding a period which is preceded by some
	  # character, and is followed by some character other than a period,
	  # if there is no following period that is followed by something
	  # other than a period (yeah, confusing, I know)
	  fn = filename.split /(?<=.)\.(?=[^.])(?!.*\.[^.])/m

	  # We now have one or two parts (depending on whether we could find
	  # a suitable period). For each of these parts, replace any unwanted
	  # sequence of characters with an underscore
	  fn.map! { |s| s.gsub /[^a-z0-9\-]+/i, '_' }

	  # Finally, join the parts with a period and return the result
	  return fn.join '.'
	end

	def set_locale
		I18n.locale = params[:locale] || I18n.default_locale
	end
end
