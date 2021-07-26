class SetDefaultPhase < ActiveRecord::Migration[5.2]
  def change
    change_column :editions, :phase, :text, default: "alpha"
  end
end
