class AddDbIndexes < ActiveRecord::Migration
  def change
    add_index :events, :band_id
    add_index :events, :venue_id
    add_index :payments, :user_id
    add_index :payments, :event_id
    add_index :payments, [:processor_id, :processor_type]
  end
end
