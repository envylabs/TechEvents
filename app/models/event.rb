class Event < ActiveRecord::Base
	attr_accessible :street, :city, :state, :country, :description, :notes, :end_time, :original_address, :latitude, :link, :longitude, :name, :newsletter, :start_time, :user_id

	belongs_to :user

	def address
		[street, city, state, country].compact.join(', ')
	end

	# Auto-fetch coordinates for :original_address and save them to the :latitude and :longitude columns
	geocoded_by :original_address
	after_validation :geocode

	# Auto-fetch correct address for the :latitude and :longitude and save it to the :street, :city, :state, and :country columns.
	# Address determined by the :original_address, provided by the user.	
	reverse_geocoded_by :latitude, :longitude do |obj,results|
		if geo = results.first
			obj.street	= geo.address.split(', ')[0]
			obj.city 	= geo.city
			obj.state	= geo.state
			obj.country = geo.country
		end
	end
	after_validation :reverse_geocode
end
