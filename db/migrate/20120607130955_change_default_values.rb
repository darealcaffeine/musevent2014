class ChangeDefaultValues < ActiveRecord::Migration
  def change
    change_column_default :payments, :state_cd, Payment.states[:new]
    change_column_default :users, :role_cd, User.roles[:user]
  end
end
