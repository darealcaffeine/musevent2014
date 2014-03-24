class EventStateChecker
  def archive_failed_raising
    count = 0
    Event.where(
        "state_cd = ? AND raising_end < ?",
        Event.states['raising'], DateTime.now
    ).each do |event|
      if event.tickets_sold < event.min_tickets
        event.update_attribute :state_cd, Event.states['archived']
        count += 1
      end
    end
    count
  end

  def archive_passed
    Event.where(
        "state_cd = ? AND date < ?",
        Event.states['planned'], DateTime.now
    ).update_all "state_cd = #{Event.states['archived']}"
  end

end