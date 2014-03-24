class VenuesController < ApplicationController
  def index
    authorize! :list, Venue
    @filter = params[:filter] ||= 'all'
    query = []
    query.append "(events_count > 0)" if @filter == 'active'
    @venues = Venue.where(query.join " AND ").page(params[:page]).per(12).order('created_at DESC')
  end

  def show
    @venue = Venue.find(params[:id])
    authorize! :show, @venue
  end

  def create
    authorize! :create, Venue
    raise BusyManagerError unless current_user.venue.nil?
    @venue = Venue.new params[:venue]
    @venue.user = current_user
    @venue.save!
    render 'show'
  end
end
