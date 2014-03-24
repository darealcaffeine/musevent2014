class EventMailer < ActionMailer::Base
  default from: "events_robot@musevent.com"

  def notify_raising_success(event, user)
    @event = event
    @user = user
    mail to: @user.email, subject: "#{@event.title} event successfully finished fund raising company"
  end

  def notify_raising_failure(event, user)
    @event = event
    @user = user
    mail to: @user.email, subject: "#{@event.title} event failed fund raising company"
  end
end
