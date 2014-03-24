class EventsController < ApplicationController
  # GET /events
  # GET /events.json
  def index
    @query = {state_cd: [Event.states[:raising], Event.states[:planned]]}
    @filtering = {state: 'none'}
    unless params[:venue_id].in? nil, ""
      @query[:venue_id] = params[:venue_id]
      @filtering[:venue] = Venue.find(params[:venue_id])
    end
    unless params[:band_id].in? nil, ""
      @query[:band_id] = params[:band_id]
      @filtering[:band] = Band.find(params[:band_id])
    end
    unless params[:state].in? nil, "", @filtering[:state]
      @query[:state_cd] = Event.states[params[:state]]
      @filtering[:state] = params[:state]
    end

    @events = Event.where(@query).page(params[:page]).per(12).order('created_at DESC')
  end

  # GET /events/1
  # GET /events/1.json
  def show
    @event = Event.find(params[:id])
  end

  # POST /events
  # POST /events.json
  def create
    @event = Event.new params[:event]
    authorize! :manage, @event
    @event.save!
    render 'show'
  end
end
