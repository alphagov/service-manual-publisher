class AddCreatedByToEditions < ActiveRecord::Migration[5.2]
  def change
    add_column :editions, :created_by_id, :integer, index: true
  end
end
