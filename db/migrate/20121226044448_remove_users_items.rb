class RemoveUsersItems < ActiveRecord::Migration
  def change
    drop_table :users_items
  end
end
