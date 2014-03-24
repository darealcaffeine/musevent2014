class CreateAmazonPayments < ActiveRecord::Migration
  def change
    create_table :amazon_payments do |t|
      t.string :sender_token, :default => ""

      t.timestamps
    end
  end
end
