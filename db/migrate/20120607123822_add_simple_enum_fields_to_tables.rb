class AddSimpleEnumFieldsToTables < ActiveRecord::Migration
  def change
    add_column :users, :role_cd, :integer
    remove_column :users, :role

    add_column :payments, :state_cd, :integer
    remove_column :payments, :state
  end
end
