class AddManagerRelations < ActiveRecord::Migration
  def up
    add_column :bands, :manager_id, :integer
    Band.all.each do |band|
      band.update_attribute :manager_id, 1
    end

    add_column :venues, :manager_id, :integer
    Venue.all.each do |venue|
      venue.update_attribute :manager_id, 1
    end
  end

  def down
    remove_column :bands, :manager_id
    remove_column :venues, :manager_id
  end
end
