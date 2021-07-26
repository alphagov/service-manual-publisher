class DropEditionsSummary < ActiveRecord::Migration[5.2]
  def change
    remove_column :editions, :summary
  end
end
