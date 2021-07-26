class RenameEditionsUser < ActiveRecord::Migration[5.2]
  def change
    rename_column :editions, :user_id, :author_id
  end
end
