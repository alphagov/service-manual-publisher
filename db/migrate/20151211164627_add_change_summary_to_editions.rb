class AddChangeSummaryToEditions < ActiveRecord::Migration[5.2]
  def change
    add_column :editions, :change_summary, :text
  end
end
