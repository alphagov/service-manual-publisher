class IndexForeignKeysInEditions < ActiveRecord::Migration[5.2]
  def change
    add_index :editions, :author_id
    add_index :editions, :content_owner_id
    add_index :editions, :guide_id
  end
end
