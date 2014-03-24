class AddEventFeatures < ActiveRecord::Migration
  def change
    add_column :events, :description, :text
    add_column :events, :raising_end, :datetime
    add_column :events, :raised_funds, :decimal
  end
end
