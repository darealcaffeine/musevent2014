module EventsHelper
  def event_metadata(event)
    res = '<div class="meta row-fluid">'
    unless event.nil?
      case event.state
        when 'raising'
          res << wrap_in_div("tickets span6", event.tickets_sold.to_s + " tickets sold")
          res << wrap_in_div("time span6", distance_of_time_in_words_to_now(event.raising_end) + " left")
        when 'planned'
          res << wrap_in_div("tickets span6", (event.max_tickets - event.tickets_sold).to_s + " tickets left")
          res << wrap_in_div("time span6", distance_of_time_in_words_to_now(event.date) + " left")
        when 'archived'
          res << wrap_in_div("tickets span6", event.tickets_sold.to_s + " tickets were sold")
          res << wrap_in_div("time span6", "Event is archived")
      end
    end
    res << "</div>"
    render inline: res
  end

  def event_progressbar(event)
    unless event.nil?
      num = 0
      case event.state
        when 'raising'
          num = event.raising_percentage
        when 'planned'
          num = 100 * event.tickets_sold / event.max_tickets
      end
      render inline: (wrap_in_div "progress#{' progress_success' if event.planned?}",
                                  "<div class=\"bar\" style=\"width: #{num}%\"></div>")
    end
  end

  def reserve_tickets_button(event)
    result = ""
    unless event.archived?
      result << "<a href=\"#{new_event_payment_path event}\" class=\"btn btn-primary\" ref=\"backbone\">"
      case event.state
        when 'raising'
          result << "Reserve"
        when 'planned'
          result << "Buy"
      end
      result << "a ticket".insert(0, ' ')
      result << " (#{number_to_currency event.price})"
      result << "</a>"
    end
    render inline: result
  end

  private

  def wrap_in_div(klass, data)
    "<div class=\"#{klass}\">#{data.to_s}</div>"
  end
end
