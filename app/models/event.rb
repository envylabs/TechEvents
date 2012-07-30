class Event < ActiveRecord::Base
	attr_accessible :street, :city, :state, :country, :description, :notes, :end_time, :end_time_date, :end_time_time, :original_address, :latitude, :link, :longitude, :name, :newsletter, :start_time, :start_time_date, :start_time_time, :user_id

	attr_accessor :start_time_date, :start_time_time, :end_time_date, :end_time_time

	validates_format_of :start_time_time, :with => /\d{1,2}:\d{2}/
	validates_format_of :end_time_time, :with => /\d{1,2}:\d{2}/

	belongs_to :user


	def self.upcoming
		self.where("start_time >= :current_time", current_time: Time.new).order(:start_time)
	end

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


	# Setup datetimes
	after_initialize :get_datetimes
	before_validation :set_datetimes

	private

	def get_datetimes
		self.start_time ||= Time.now
		self.start_time_date ||= self.start_time.to_date.to_s(:db)
		self.start_time_time ||= "#{'%02d' % self.start_time.hour}:#{'%02d' % self.start_time.min}"
		self.end_time ||= Time.now + 1.hour
		self.end_time_date ||= self.start_time.to_date.to_s(:db)
		self.end_time_time ||= "#{'%02d' % self.end_time.hour}:#{'%02d' % self.end_time.min}"
	end

	def set_datetimes
		self.start_time = "#{self.start_time_date} #{self.start_time_time}:00"
		self.end_time = "#{self.end_time_date} #{self.end_time_time}:00"
	end
end
