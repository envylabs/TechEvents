class EventsController < ApplicationController
  load_and_authorize_resource
  skip_load_resource only: :index

  # GET /events
  # GET /events.json
  def index
    # Do not use CanCan load_resource here (see skip_load_resource above)
    @events = Event.upcoming

    @events = @events.group_by{ |u| u.start_time.beginning_of_month }
    @current_month = Time.now.strftime("%B")

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
    # @event is already loaded and authorized
    # @event = Event.new(params[:event])
    @event.user = current_user

    if !params[:event][:group_id].blank?
      @event.group = Group.find(params[:event][:group_id])
    elsif !params[:group][:name].blank?
      @event.group = Group.create({name: params[:group][:name]})
    else
      @event.group = nil
    end

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
    @event.group = Group.find(params[:event][:group_id]) if !params[:event][:group_id].blank?

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to events_path, notice: 'Event was successfully updated.' }
      else
        format.html { render action: "edit" }
      end
    end
  end
end
