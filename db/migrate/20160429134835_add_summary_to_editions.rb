class AddSummaryToEditions < ActiveRecord::Migration[5.2]
  def change
    add_column :editions, :summary, :text
  end
end
