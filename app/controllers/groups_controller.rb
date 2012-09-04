class GroupsController < ApplicationController
	# GET /groups/:id/last_event.json
	def last_event
		# Get the last event for this group and authorize it
		last_event = Group.find(params[:id]).events.last
		authorize! :show, last_event

		# Process all the time and date stuff
		today = Time.now

		start_parse = Time.parse(last_event.start_time.to_s)
		start_parse > today ? (new_start_time = start_parse + 1.month) : (new_start_time = today)

		end_parse = Time.parse(last_event.end_time.to_s)
		start_parse > today ? (new_end_time = end_parse + 1.month) : (new_end_time = today + 1.day)

		# Build a JSON response and deliver it
		response = {
			origin: {
				id:			last_event.id,
			},
			name:			last_event.name,
			description:	last_event.description,
			image: 			last_event.image.url,
			link:			last_event.link,
			address:		last_event.address,
			notes:			last_event.notes,
			start_date:		new_start_time.strftime('%Y-%m-%d'),
			start_time:		new_start_time.strftime('%H:%M'),
			end_date:		new_end_time.strftime('%Y-%m-%d'),
			end_time:		new_end_time.strftime('%H:%M'),
		}

		render :json => response
	end
end