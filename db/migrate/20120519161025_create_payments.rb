class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :user_id
      t.integer :event_id
      t.decimal :amount
      t.string :state, :default => 'new'

      t.timestamps
    end
  end
end
