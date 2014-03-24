class ChangeItemManagement < ActiveRecord::Migration
  def change
    drop_table :bands_users
    drop_table :users_venues
    add_column :bands, :user_id, :integer
    add_column :venues, :user_id, :integer
  end
end
