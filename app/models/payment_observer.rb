class PaymentObserver < ActiveRecord::Observer
  def after_save(payment)
    check_event_state payment
    refresh_event_fields payment
  end

  def check_event_state(payment)
    event = payment.event
    if event.raising?
      tickets_in_reserved_payments = event.payments.where("state_cd = ?", Payment.reserved).sum('tickets_count')
      if tickets_in_reserved_payments >= event.min_tickets
        event.update_attribute :state, 'planned'
      end
    end
  end

  def refresh_event_fields(payment)
  end
end
