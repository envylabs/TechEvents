class GroupsController < ApplicationController
	# GET /groups/:id/last_event.json
	def last_event
		# Get the last event for this group and authorize it
		last_event = Group.find(params[:id]).events.last
		authorize! :show, last_event

		# Process all the time and date stuff
		today = Time.zone.now

		start_parse = Time.zone.parse(last_event.start_at.to_s)
		start_parse > today ? (new_start_at = start_parse + 1.month) : (new_start_at = today)

		end_parse = Time.zone.parse(last_event.end_at.to_s)
		start_parse > today ? (new_end_at = end_parse + 1.month) : (new_end_at = today + 1.day)

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
			start_date:		new_start_at.strftime('%Y-%m-%d'),
			start_time:		new_start_at.strftime('%H:%M'),
			end_date:		new_end_at.strftime('%Y-%m-%d'),
			end_time:		new_end_at.strftime('%H:%M'),
		}

		render :json => response
	end
end