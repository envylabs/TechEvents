class GroupsController < ApplicationController
	# GET /groups/:id/last_event.json
	def last_event
		# Get the last event for this group and authorize it
		last_event = Group.find(params[:id]).events.last
		authorize! :show, last_event

		# Build a JSON response and deliver it
		new_start_time =  Time.parse(last_event.start_time.to_s) + 1.month
		new_end_time = Time.parse(last_event.end_time.to_s) + 1.month

		response = {
			origin: {
				id:					last_event.id,
			},
			name:			last_event.name,
			description:	last_event.description,
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