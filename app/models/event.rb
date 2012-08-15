class Event < ActiveRecord::Base
	attr_accessible :street, :city, :state, :country, :description, :notes, :end_time, :end_time_date, :end_time_time, :address_tbd, :original_address, :latitude, :link, :longitude, :name, :newsletter, :start_time, :start_time_date, :start_time_time, :user_id, :group_id

	attr_accessor :start_time_date, :start_time_time, :end_time_date, :end_time_time

	validates_presence_of :name
	validates_presence_of :description
	validates_presence_of :start_time
	validates_presence_of :end_time
	validates_format_of :start_time_time, :with => /\d{1,2}:\d{2}/
	validates_format_of :end_time_time, :with => /\d{1,2}:\d{2}/

	belongs_to :user
	belongs_to :group


	def self.upcoming
		self.where("start_time >= :current_time", current_time: Time.new).order(:start_time)
	end

	def address
		if !address_tbd
			[street, city, state, country].compact.join(', ')
		else
			nil
		end
	end

	def map_link
		if !address_tbd
			if !address.blank?
				"<a href='https://maps.google.com/maps?q=#{address}&amp;ll=#{latitude},#{longitude}&amp;z=17' target='blank'>#{street} in #{city}</a>".html_safe
			else
				"Address is being processed"
			end
		else
			"Address to be determined"
		end
	end

	def hosted_by_group
		group ? "Hosted by #{group.name}" : "No host group"
	end


	# Auto-fetch coordinates for :original_address and save them to the :latitude and :longitude columns
	geocoded_by :original_address

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

	# Setup datetimes
	after_initialize :get_datetimes
	before_validation :set_datetimes

	# Geocode via dealyed_job on after_create and after_update
	after_save :invoke_geocoder


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

	def invoke_geocoder
		Delayed::Job.enqueue(EventJob.new(self.id))
	end
end
