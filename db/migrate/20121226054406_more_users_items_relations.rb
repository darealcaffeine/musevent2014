class MoreUsersItemsRelations < ActiveRecord::Migration
  def change
    remove_column :bands, :manager_id
    remove_column :venues, :manager_id

    create_table :bands_users, id: false do |t|
      t.integer :band_id
      t.integer :user_id
    end

    create_table :users_venues, id: false do |t|
      t.integer :venue_id
      t.integer :user_id
    end
  end
end
