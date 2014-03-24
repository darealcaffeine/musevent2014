class RemoveEventRaisedFundsColumn < ActiveRecord::Migration
  def up
    remove_column :events, :raised_funds
  end

  def down
    add_column :events, :raised_funds, :decimal
    Events.includes(:payments).all.each do |event|
      event.raised_funds = event.payments.sum('amount')
    end
  end
end
