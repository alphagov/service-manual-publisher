class DropEditionsSummary < ActiveRecord::Migration
  def change
    remove_column :editions, :summary
  end
end
