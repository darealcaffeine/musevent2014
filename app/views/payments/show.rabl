object @payment
attributes :id, :event_id, :amount, :created_at, :updated_at, :processor_id, :processor_type, :state, :tickets_count,
           :event_title, :band_id, :venue_id
unless @authorization_url.nil?
  node :authorization_url do
    @authorization_url
  end
end