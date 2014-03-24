collection @events
attributes :id, :title, :date, :min_tickets, :max_tickets, :price, :state, :raising_end, :band_id, :venue_id,
           :created_at, :updated_at, :description, :band_title, :venue_title, :tickets_sold
node :picture do |event|
  {
      medium: event.picture.url(:medium),
      thumb: event.picture.url(:thumb),
      original: event.picture.url(:original)
  }
end