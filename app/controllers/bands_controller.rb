class BandsController < ApplicationController
  def index
    authorize! :list, Band
    @filter = params[:filter] ||= 'all'
    query = []
    query.append "(events_count > 0)" if @filter == 'active'
    @bands = Band.where(query.join " AND ").page(params[:page]).per(12).order('created_at DESC')
  end

  def show
    @band = Band.find(params[:id])
    authorize! :show, @band
  end
end
