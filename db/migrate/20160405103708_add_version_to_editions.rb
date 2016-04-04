class AddVersionToEditions < ActiveRecord::Migration
  def change
    add_column :editions, :version, :integer, index: true
  end
end
