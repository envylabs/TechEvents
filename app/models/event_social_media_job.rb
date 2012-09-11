class EventSocialMediaJob < Struct.new(:event_id) 
	def perform
		event = Event.find(event_id)

		post_to_social_at_1 = event.start_time - 4.hours
		post_to_social_at_2 = event.start_time - 15.minutes

		if event.update_attributes(post_to_social_at: post_to_social_at_1)
			event.post_twitter
		end

		if event.update_attributes(post_to_social_at: post_to_social_at_2)
			event.post_twitter
		end
	end
end