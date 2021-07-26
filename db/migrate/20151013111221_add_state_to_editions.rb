class AddStateToEditions < ActiveRecord::Migration[5.2]
  def change
    add_column :editions, :state, :text
  end
end
