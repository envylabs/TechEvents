class User < ActiveRecord::Base
	attr_accessible :admin, :email, :handle, :provider, :twitter_token, :twitter_secret, :facebook_token, :uid

	has_many :events

	validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, allow_nil: true


	def self.from_omniauth(auth)
		user = self.where(auth.slice('provider', 'uid')).first
		user ? login_from_omniauth(user, auth) : create_from_omniauth(auth)
	end

	def process_email_update(new_email)
		old_email = self.email

		if update_attributes(email: new_email) && (subscribed_to_newsletter? || old_email == nil)
			if old_email != nil
				Gibbon.listUnsubscribe({ id: ENV['MC_LIST_ID'], email_address: old_email, double_optin: false })
			end

			Gibbon.listSubscribe({ id: ENV['MC_LIST_ID'], email_address: new_email, double_optin: false })

			return true
		else
			return false
		end
	end

	def admin?
		self.admin == true ? true : false
	end

	def make_admin
		self.update_attributes(admin: true) ? true : false
	end

	def remove_admin(current_user)
		(self != current_user && self.update_attributes(admin: false)) ? true : false
	end


	private

	def self.login_from_omniauth(user, auth)
		if user.twitter_token != auth['credentials']['token']
			user.update_attributes(twitter_token: auth['credentials']['token'])
		end

		if user.twitter_secret != auth['credentials']['secret']
			user.update_attributes(twitter_secret: auth['credentials']['secret'])
		end

		return user
	end

	def self.create_from_omniauth(auth)
		create! do |user|
			user.provider = auth['provider']
			user.uid = auth['uid']
			user.twitter_token = auth['credentials']['token']
			user.twitter_secret = auth['credentials']['secret']
			user.handle = auth['info']['nickname']
			user.admin = false
		end
	end

	def subscribed_to_newsletter?
		Gibbon.listMemberInfo(id: ENV['MC_LIST_ID'], email_address: [self.email])['success']
	end
end
