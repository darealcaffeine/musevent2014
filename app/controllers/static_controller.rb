# This controller renders view that corresponds to permalink passed as URL parameter
class StaticController < ApplicationController
  VIEW_PREFIX = "static"

  def show
    permalink = params[:permalink] || 'index'
    if template_exists? permalink, VIEW_PREFIX
      render "#{VIEW_PREFIX}/#{permalink}"
    else
      raise StaticPageMissing, "Static page '#{permalink}' not found"
    end
  end

  def application
    render 'application', layout: false
  end
end
