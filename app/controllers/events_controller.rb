class EventsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource only: [:index, :create, :calendar, :feed]
  skip_authorize_resource only: [:calendar, :feed]

  # GET /events
  # GET /events.json
  def index
    # Do not use CanCan load_resource here (see skip_load_resource above)
    @data = Event.data_for_list

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /events/new
  # GET /events/new.json
  def new
    # @event is already loaded and authorized
    # @event = Event.new

    @groups = Group.all

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /events/1/edit
  def edit
    # @event is already loaded and authorized
    # @event = Event.find(params[:id])

    @groups = Group.all
  end

  # POST /events
  # POST /events.json
  def create
    # Do not use CanCan load_resource here (see skip_load_resource above)
    respond_to do |format|
      if Event.add_event(params, current_user)
        format.html { redirect_to events_path, notice: 'Event was successfully created.' }
      else
        format.html { render action: "new" }
      end
    end    
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    # @event is already loaded and authorized
    # @event = Event.find(params[:id])
    @groups = Group.all

    @event.group = Group.find(params[:event][:group_id]) if !params[:event][:group_id].blank?

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to events_path, notice: 'Event was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end

  # GET /events/1/calendar
  def calendar
    # Do not use CanCan load_resource here (see skip_load_resource above)
    # Load the event's iCal object
    event = Event.find(params[:id])
    cal = event.to_ical

    # Create a safe filename for the event's ics file
    filename = sanitize_filename(event.name + ".ics")

    # Respond to the request with the calendar event as an .ics file streamed to the client
    respond_to do |format|
      format.ics { send_data(cal.export, filename: filename, disposition: "attachment; filename=" + filename, type: "text/calendar") }
    end
  end

  # GET /events/feed
  def feed
    # TODO: Actually make this feed valid and working

    # Load all of the feed's iCal objects
    events = Event.all
    cal = Event.to_feed(events)

    # Respond to the request with the feed as text
    respond_to do |format|
      format.ics { send_data(cal.export, filename: "feed.ics", disposition: "attachment; filename=feed.ics", type: "text/calendar") }
    end
  end

  def toggle_newsletter
    @event.toggle_newsletter

    respond_to do |format|
      format.js
    end
  end
end
