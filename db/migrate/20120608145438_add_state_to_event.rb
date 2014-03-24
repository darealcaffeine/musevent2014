class AddStateToEvent < ActiveRecord::Migration
  def change
    add_column :events, :state_cd, :integer, default: Event.raising
  end
end
