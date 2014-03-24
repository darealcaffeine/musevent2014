class ConnectVenuesToEvents < ActiveRecord::Migration
  def up
    add_column :events, :venue_id, :integer
    Event.all.each do |ev|
      ev.venue_id = Venue.create!(title: ev.venue,
                                  description: "Dummy description, will be changed shortly",
                                  address: "Dummy address").id
      ev.save!
    end
    remove_column :events, :venue
  end

  # Irreversible migration
end
