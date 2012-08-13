class User < ActiveRecord::Base
	attr_accessible :admin, :email, :handle, :provider, :token, :uid

	has_many :events

	validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, allow_nil: true


	def self.from_omniauth(auth)
		where(auth.slice('provider', 'uid')).first || create_from_omniauth(auth)
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


	private

	def self.create_from_omniauth(auth)
		create! do |user|
			user.provider = auth['provider']
			user.uid = auth['uid']
			user.token = auth['credentials']['token']
			user.handle = auth['info']['nickname']
			user.admin = false
		end
	end

	def subscribed_to_newsletter?
		Gibbon.listMemberInfo(id: ENV['MC_LIST_ID'], email_address: [self.email])['success']
	end
end
