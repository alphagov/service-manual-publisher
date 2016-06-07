class AddCreatedByToEditions < ActiveRecord::Migration
  def change
    add_column :editions, :created_by_id, :integer, index: true
  end
end
