class MuseventError < StandardError
end

class RenderedError < MuseventError
  attr_accessor :redirection_method_name

  def redirection_method_name
    @redirection_method_name || default_redirection_method_name
  end

  def default_redirection_method_name
    'root_url'
  end
end

class NonRenderedError < MuseventError
end

class BandsControllerError < RenderedError
  def default_redirection_method_name
    'bands_url'
  end
end

class EventsControllerError < RenderedError
  def default_redirection_method_name
    'events_url'
  end
end

class PaymentsControllerError < RenderedError
  def default_redirection_method_name
    'payments_url'
  end
end

class StaticPageMissing < RenderedError
  def default_redirection_method_name
    'root_url'
  end
end

class PaymentProcessingError < NonRenderedError
end

class OperationForbiddenError < NonRenderedError
end

class PreconditionsError < PaymentProcessingError
end

class ReservationFailedError < PaymentProcessingError
end

class ApiInteractionError < PaymentProcessingError
end

class MalformedServiceResponseError < PaymentProcessingError
end

class BusyManagerError < RenderedError
end