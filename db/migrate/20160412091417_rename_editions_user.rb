class RenameEditionsUser < ActiveRecord::Migration
  def change
    rename_column :editions, :user_id, :author_id
  end
end
