class ChangeDefaultPaymentState < ActiveRecord::Migration
  def change
    change_column_default :payments, :state_cd, Payment.states[:created]
  end
end
