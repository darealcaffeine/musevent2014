class CreateDummyProcessors < ActiveRecord::Migration
  def change
    create_table :dummy_processors do |t|

      t.timestamps
    end
  end
end
