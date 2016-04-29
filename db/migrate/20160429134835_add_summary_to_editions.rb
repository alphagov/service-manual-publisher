class AddSummaryToEditions < ActiveRecord::Migration
  def change
    add_column :editions, :summary, :text
  end
end
