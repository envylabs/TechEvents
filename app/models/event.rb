class Event < ActiveRecord::Base
	attr_protected
	attr_accessor :start_time_date, :start_time_time, :end_time_date, :end_time_time

	validates_presence_of :name
	validates_presence_of :description
	validates_presence_of :start_time
	validates_presence_of :end_time
	validates_format_of :start_time_time, :with => /\d{1,2}:\d{2}/
	validates_format_of :end_time_time, :with => /\d{1,2}:\d{2}/

	belongs_to :user
	belongs_to :group


	# Image uploading
	mount_uploader :image, EventImageUploader

	# Setup datetimes
	after_initialize :get_datetimes
	before_validation :set_datetimes

	def get_datetimes
		self.start_time ||= Time.now
		self.start_time_date ||= self.start_time.to_date.to_s(:db)
		self.start_time_time ||= "#{'%02d' % self.start_time.hour}:#{'%02d' % self.start_time.min}"
		self.end_time ||= Time.now + 1.hour
		self.end_time_date ||= self.start_time.to_date.to_s(:db)
		self.end_time_time ||= "#{'%02d' % self.end_time.hour}:#{'%02d' % self.end_time.min}"
	end
	private :get_datetimes

	def set_datetimes
		self.start_time ||= "#{self.start_time_date} #{self.start_time_time}:00"
		self.end_time ||= "#{self.end_time_date} #{self.end_time_time}:00"
	end
	private :set_datetimes

	# Geocode via dealyed_job on after_create and after_update
	after_create :invoke_geocoder

	# Social media posting logic
	after_create :schedule_social_media

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

	def invoke_geocoder
		Delayed::Job.enqueue(EventGeocodeJob.new(self.id))
	end
	private :invoke_geocoder

	def self.upcoming
		self.where("start_time >= :current_time", current_time: Time.now).order(:start_time)
	end

	def self.data_for_list
		{
			current_month: Time.now.strftime("%B"),
			events: upcoming.group_by{ |u| u.start_time.beginning_of_month }
		}
	end

	def self.add_event(params, user)
		# Variables
		event = Event.new(params[:event], user: user)
		groups = Group.all
		last_event = params[:event][:group_id] ? Group.find(params[:event][:group_id]).events.last : nil

		# Set current_user
		# event.user = user

		# Set group
		if !params[:event][:group_id].blank?
			event.group = Group.find(params[:event][:group_id])
		elsif !params[:group][:name].blank?
			event.group = Group.create({name: params[:group][:name]})
		else
			event.group = nil
		end

		# Set default image
		if last_event.image? && params[:event][:image].blank?
			event.image = last_event.image
		end

		# Save the event
		return event.save
	end

	def toggle_newsletter
		if newsletter == false || newsletter.blank?
			add_to_newsletter
		else
			remove_from_newsletter
		end
	end

	def add_to_newsletter
		update_attributes(newsletter: true)
	end

	def remove_from_newsletter
		update_attributes(newsletter: false)
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
				I18n.t 'events_upcoming_events.event_entry.address.link_html', url: "https://maps.google.com/maps?q=#{address}&amp;ll=#{latitude},#{longitude}&amp;z=17", street: street, city: city
			else
				I18n.t 'events_upcoming_events.event_entry.address.processing'
			end
		else
			I18n.t 'events_upcoming_events.event_entry.address.tbd' 
		end
	end

	def hosted_by_group
		group ? I18n.t("events_upcoming_events.event_entry.hosted_by", name: group.name) : I18n.t("events_upcoming_events.event_entry.no_host")
	end

	def to_ical
		RiCal.Calendar do |calendar|
			calendar.event do |details|
				details.summary     = self.name
				details.description = "Description:\n" + self.description + "\n\nNotes:\n" + self.notes
				details.dtstart     = Time.parse(self.start_time.to_s).getutc
				details.dtend       = Time.parse(self.end_time.to_s).getutc
				details.location    = self.address
			end
		end
	end

	def self.to_feed(events)
		RiCal.Calendar do |calendar|
			calendar.add_x_property 'X-WR-CALNAME', 'Tech Events'
			events.each do |event|
				calendar.event do |details|
					details.summary     = event.name
					details.description = "Description:\n" + event.description + "\n\nNotes:\n" + event.notes
					details.dtstart     = Time.parse(event.start_time.to_s).getutc
					details.dtend       = Time.parse(event.end_time.to_s).getutc
					details.location    = event.address
				end
			end
		end
	end

	def schedule_social_media
		delay(run_at: first_reminder_at).post_twitter(:first, first_reminder_at)
		delay(run_at: last_reminder_at).post_twitter(:last, last_reminder_at)
	end

	def first_reminder_at
		# start_time - 4.hours + (rand(11) - 5)
		start_time - 4.hours
	end
	private :first_reminder_at

	def last_reminder_at
		start_time - 15.minutes
	end
	private :last_reminder_at

	def post_twitter(iteration, post_to_social_at)
		# Check to see if the day this event gets posted to Twitter occurs on the same day as the event
		if Time.at(post_to_social_at).to_date === Time.at(start_time).to_date
			if iteration == :first
				social_media_message = "Don't forget! #{name} starts at #{'%02d' % self.start_time.hour}:#{'%02d' % self.start_time.min}."
			elsif iteration == :last
				social_media_message = "Heads up! #{name} starts at #{'%02d' % self.start_time.hour}:#{'%02d' % self.start_time.min}."
			end
		else
			if iteration == :first
				social_media_message = "Don't forget! #{name} starts tomorrow at #{'%02d' % self.start_time.hour}:#{'%02d' % self.start_time.min}."
			elsif iteration == :last
				social_media_message = "Heads! #{name} starts tomorrow at #{'%02d' % self.start_time.hour}:#{'%02d' % self.start_time.min}."
			end
		end

		client = Twitter::Client.new(:oauth_token => user.twitter_token, :oauth_token_secret => user.twitter_secret)
		client.update(social_media_message)
		
		if !self.posted_twitter
			self.update_attributes(posted_twitter: true)
		end
	end
	private :post_twitter
end
