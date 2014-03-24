class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :title
      t.string :venue
      t.string :band
      t.datetime :date
      t.integer :min_tickets
      t.integer :max_tickets
      t.decimal :price

      t.timestamps
    end
  end
end
