class RemoveCounterCache < ActiveRecord::Migration
  def change
    remove_column :events, :tickets_sold
  end
end
