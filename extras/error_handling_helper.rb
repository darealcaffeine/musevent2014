module ErrorHandlingHelper
  def do_redirect_for(error, options={})
    target = root_url
    if error.instance_of? RenderedError
      target = self.send(error.redirection_method_name)
    elsif request.env["HTTP_REFERER"]
      target = :back
    end
    redirect_to target, options
  end

  def render_error_message(message, options={})
    hash = {json: {status: "error", message: message}}.merge! options
    render hash
  end

  def status_for_error(error)
    return 400 if error.is_a? RenderedError
    return 404 if error.is_a? ActiveRecord::RecordNotFound
    return 403 if error.is_a? CanCan::AccessDenied
    500
  end

  def log_write(error)
    Rails.logger.error error.inspect
    error.backtrace.each do |line|
      Rails.logger.error line
    end
  end
end