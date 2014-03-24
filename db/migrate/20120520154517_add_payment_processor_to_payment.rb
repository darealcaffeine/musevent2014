class AddPaymentProcessorToPayment < ActiveRecord::Migration
  def change
    add_column :payments, :processor_id, :integer
  end
end
