class AddTicketsCountToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :tickets_count, :integer, default: 1
  end
end
