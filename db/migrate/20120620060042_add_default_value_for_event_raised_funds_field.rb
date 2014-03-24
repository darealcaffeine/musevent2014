class AddDefaultValueForEventRaisedFundsField < ActiveRecord::Migration
  def up
    change_column_default :events, :raised_funds, 0
  end

  def down
    change_column_default :events, :raised_funds, nil
  end
end
