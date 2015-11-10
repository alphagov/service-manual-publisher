class SetDefaultPhase < ActiveRecord::Migration
  def change
    change_column :editions, :phase, :text, default: 'alpha'
  end
end
