class UserController < ApplicationController
	before_filter :require_authentication!

	def edit
		@user = current_user
	end

	def update
		old_email = current_user.email
		newsletter = Gibbon.listMemberInfo(id: ENV['MC_LIST_ID'], email_address: [current_user.email])['success']

		if session[:post_auth_path]
			url = session[:post_auth_path]
			session[:post_auth_path] = nil
		else
			url = root_path
		end

		if current_user.email != params[:user][:email]
			if current_user.update_attribute(:email, params[:user][:email])
				puts "Updating user's email address, subscribing new one, and unsubscribing old one (if old one exsisted)."

				if old_email != nil
					Gibbon.listUnsubscribe({ id: ENV['MC_LIST_ID'], email_address: old_email, double_optin: false })
				end
				
				Gibbon.listSubscribe({ id: ENV['MC_LIST_ID'], email_address: params[:user][:email], double_optin: false })

				redirect_to url, notice: "Email address updated!"
			else
				raise "EmailWasNotUpdated"
			end
		end
	end
end
