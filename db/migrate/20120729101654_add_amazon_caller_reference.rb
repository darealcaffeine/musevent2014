class AddAmazonCallerReference < ActiveRecord::Migration
  def change
    add_column :amazon_processors, :caller_reference, :string
  end
end
