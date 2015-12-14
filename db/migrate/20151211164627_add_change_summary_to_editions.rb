class AddChangeSummaryToEditions < ActiveRecord::Migration
  def change
    add_column :editions, :change_summary, :text
  end
end
