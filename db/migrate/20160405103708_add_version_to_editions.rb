class AddVersionToEditions < ActiveRecord::Migration[5.2]
  def change
    add_column :editions, :version, :integer, index: true
  end
end
