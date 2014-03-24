class CreateUsersItems < ActiveRecord::Migration
  def change
    create_table :users_items do |t|
      t.integer :user_id
      t.string :item_type
      t.integer :item_id

      t.timestamps
    end
  end
end
