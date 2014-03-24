class CreateBands < ActiveRecord::Migration
  def change
    create_table :bands do |t|
      t.string :title
      t.text :description

      t.timestamps
    end
  end
end
