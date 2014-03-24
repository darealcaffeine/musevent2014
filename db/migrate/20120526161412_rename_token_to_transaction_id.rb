class RenameTokenToTransactionId < ActiveRecord::Migration
  def change
    rename_column :amazon_payments, :sender_token, :transaction_id
  end
end
