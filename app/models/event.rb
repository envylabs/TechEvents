class Event < ActiveRecord::Base
	attr_protected
	attr_accessor :start_date, :start_time, :default_start_at, :end_date, :end_time, :default_end_at

	validates_presence_of :name
	validates_presence_of :description
	# validates_presence_of :start_at
	# validates_presence_of :end_at
	# validates_format_of :start_time, :with => /\d{1,2}:\d{2}/
	# validates_format_of :end_time, :with => /\d{1,2}:\d{2}/

	belongs_to :user
	belongs_to :group


	# Image uploading
	mount_uploader :image, EventImageUploader

	# Setup datetimes
	before_validation :process_datetime_input

	def initialize(*args)
		super(*args)
		init_datetimes
		self
	end

	def init_datetimes
		# These two blocks should never run if a start_date and start_time attr_accessor is present, because then they'll wipe out whatever was on the form
		if self.start_date.blank? && self.start_time.blank?
			self.start_at ||= Time.zone.now
			self.start_date = self.start_at.to_date.to_s(:db)
			self.start_time = "#{'%02d' % self.start_at.hour}:#{'%02d' % self.start_at.min}"
			self.default_start_at = Time.zone.parse("#{self.start_date} #{self.start_time}:00")
		end

		if self.end_date.blank? && self.end_time.blank?
			self.end_at ||= Time.zone.now + 1.hour
			self.end_date = self.end_at.to_date.to_s(:db)
			self.end_time = "#{'%02d' % self.end_at.hour}:#{'%02d' % self.end_at.min}"
			self.default_end_at = Time.zone.parse("#{self.end_date} #{self.end_time}:00")
		end
	end
	public :init_datetimes

	def process_datetime_input
		inputed_start_at = Time.zone.parse("#{self.start_date} #{self.start_time}:00")
		inputed_end_at = Time.zone.parse("#{self.end_date} #{self.end_time}:00")

		if self.default_start_at != inputed_start_at
			self.start_at = inputed_start_at
		end

		if self.default_end_at != inputed_end_at
			self.end_at = inputed_end_at
		end
	end
	private :process_datetime_input

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
		self.where("start_at >= :current_time", current_time: Time.zone.now).order(:start_at)
	end

	def self.newsletter_events
		self.where("start_at >= :beginning_of_month AND start_at <= :end_of_month AND newsletter = :newsletter_status", beginning_of_month: Time.zone.now.beginning_of_month, end_of_month: Time.zone.now.end_of_month, newsletter_status: true).order(:start_at)
	end

	def self.data_for_list
		{
			current_month: Time.zone.now.strftime("%B"),
			events: upcoming.group_by{ |u| u.start_at.beginning_of_month }
		}
	end

	def self.add_event(params, user)
		# Variables
		event = Event.new(params[:event], user: user)
		groups = Group.all
		last_event = params[:event][:group_id] ? Group.find(params[:event][:group_id]).events.last : nil

		# Set current_user
		event.user = user

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
		event.save
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
				details.dtstart     = Time.zone.parse(self.start_at.to_s).getutc
				details.dtend       = Time.zone.parse(self.end_at.to_s).getutc
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
					details.dtstart     = Time.zone.parse(event.start_at.to_s).getutc
					details.dtend       = Time.zone.parse(event.end_at.to_s).getutc
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
		# start_at - 4.hours + (rand(11) - 5)
		start_at - 4.hours
	end
	private :first_reminder_at

	def last_reminder_at
		start_at - 15.minutes
	end
	private :last_reminder_at

	def post_twitter(iteration, post_to_social_at)
		# Check to see if the day this event gets posted to Twitter occurs on the same day as the event
		if Time.zone.at(post_to_social_at).to_date === Time.zone.at(start_at).to_date
			if iteration == :first
				social_media_message = "Don't forget! #{name} starts at #{'%02d' % self.start_at.hour}:#{'%02d' % self.start_at.min}."
			elsif iteration == :last
				social_media_message = "Heads up! #{name} starts at #{'%02d' % self.start_at.hour}:#{'%02d' % self.start_at.min}."
			end
		else
			if iteration == :first
				social_media_message = "Don't forget! #{name} starts tomorrow at #{'%02d' % self.start_at.hour}:#{'%02d' % self.start_at.min}."
			elsif iteration == :last
				social_media_message = "Heads! #{name} starts tomorrow at #{'%02d' % self.start_at.hour}:#{'%02d' % self.start_at.min}."
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
