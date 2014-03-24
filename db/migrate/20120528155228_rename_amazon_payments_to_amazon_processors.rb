class RenameAmazonPaymentsToAmazonProcessors < ActiveRecord::Migration
  def change
    rename_table :amazon_payments, :amazon_processors
  end
end
