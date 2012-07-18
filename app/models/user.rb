class User < ActiveRecord::Base
	attr_accessible :admin, :email, :handle, :provider, :token, :uid

	has_many :events

	def self.from_omniauth(auth)
		where(auth.slice('provider', 'uid')).first || create_from_omniauth(auth)
	end

	def self.create_from_omniauth(auth)
		create! do |user|
			user.provider = auth['provider']
			user.uid = auth['uid']
			user.token = auth['credentials']['token']
			user.handle = auth['info']['nickname']
			user.admin = false
		end
	end
end
