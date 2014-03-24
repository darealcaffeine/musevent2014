class EventObserver < ActiveRecord::Observer
  def after_save(event)
    if event.state_changed?
      if event.planned?
        settle_reserved_payments event
        notify_raising_success event
      elsif event.archived? and event.state_was == 'raising'
        notify_raising_failure event
      end
    end
  end

  def settle_reserved_payments(event)
    event.payments.where(state_cd: Payment.reserved).each do |payment|
      payment.processor.settle
    end
  end

  def notify_raising_success(event)
    users = event.payments.map { |payment| payment.user }
    mails = users.map { |user| EventMailer.notify_raising_success event, user }
    mails.each { |mail| mail.deliver }
  end

  def notify_raising_failure(event)
    users = event.payments.map { |payment| payment.user }
    mails = users.map { |user| EventMailer.notify_raising_failure event, user }
    mails.each { |mail| mail.deliver }
  end
end
