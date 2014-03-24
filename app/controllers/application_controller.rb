# This is base class for all Musevent controllers
class ApplicationController < ActionController::Base
  protect_from_forgery

  include ErrorHandlingHelper

  rescue_from StandardError, with: :rescue_error

  before_filter :setup_context

  private

  def setup_context
    if user_signed_in?
      gon.current_user = current_user.as_json
      if current_user.venue
        gon.current_venue = current_user.venue.as_json
      end
    end
    gon.processor_types = Payment.named_processor_types
    gon.notifications = flash
  end

  # This method is used for rendering error responses. It uses functions
  # from #ErrorHandlingHelper module to take proper actions depending on
  # error type. Best practice is to use it like this:
  #    rescue_from StandardError, with:0[] :rescue_error
  # Please note that it works only for #StandardError.
  #
  # === Parameters
  # <tt>error</tt> this catches the error that was raised
  def rescue_error(error)
    log_write error
    respond_to do |format|
      format.html do
        flash[:error] = error.message
        do_redirect_for error, status: status_for_error(error)
      end
      format.json do
        render_error_message error.message, status: status_for_error(error)
      end
    end
  end

end
