class AddCacheForEventTicketsSold < ActiveRecord::Migration
  def change
    add_column :events, :ts, :integer, null: false, default: 0
    Event.all.each do |event|
      event.update_attribute :ts, event.tickets_sold
    end
    rename_column :events, :ts, :tickets_sold
  end
end
