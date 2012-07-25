class EventsController < ApplicationController
  load_and_authorize_resource

  # GET /events
  # GET /events.json
  def index
    # Override CanCan load and authorize with custom list method from Event model.
    # @events is already loaded and authorized
    # @events = Event.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /events/new
  # GET /events/new.json
  def new
    # @event is already loaded and authorized
    # @event = Event.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /events/1/edit
  def edit
    # @event is already loaded and authorized
    # @event = Event.find(params[:id])
  end

  # POST /events
  # POST /events.json
  def create
    # @event is already loaded and authorized
    # @event = Event.new(params[:event])
    @event.user = current_user

    respond_to do |format|
      if @event.save
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

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to events_path, notice: 'Event was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end
end
