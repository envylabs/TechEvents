class Event < ActiveRecord::Base
	attr_accessible :description, :end_time, :human_address, :latitude, :link, :longitude, :name, :newsletter, :start_time, :user_id

	belongs_to :user
end
