class AddCounterCaches < ActiveRecord::Migration
  def change
    add_column :venues, :events_count, :integer, default: 0, null: false
    add_column :bands, :events_count, :integer, default: 0, null: false
    [Venue, Band].each do |klass|
      klass.includes(:events).all.each do |item|
        item.update_attribute :events_count, item.events.count
      end
    end
  end
end
