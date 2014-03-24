collection @payments
attributes :id, :event_id, :amount, :created_at, :updated_at, :processor_id, :processor_type, :state, :tickets_count
node :event_title do |payment|
  payment.event_title
end