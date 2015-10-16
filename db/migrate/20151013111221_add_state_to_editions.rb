class AddStateToEditions < ActiveRecord::Migration
  def change
    add_column :editions, :state, :text
  end
end
