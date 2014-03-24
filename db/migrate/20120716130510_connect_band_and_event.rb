class ConnectBandAndEvent < ActiveRecord::Migration
  def up
    add_column :events, :band_id, :integer
    Event.all.each do |ev|
      ev.band_id =  Band.create!(title: ev.band, description: "Dummy description, will be changed shortly").id
      ev.save
    end
    remove_column :events, :band
  end

  # this migration cannot be rolled back because we actually are not in production now, and writing rollback script
  # would take too long
end
