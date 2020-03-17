class ChangeEditionPhasesToBeta < ActiveRecord::Migration
  def change
    change_column :editions, :phase, :text, default: "beta"
    execute "UPDATE editions SET phase='beta' WHERE phase='alpha'"
  end
end
