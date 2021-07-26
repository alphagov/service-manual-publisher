class IndexForeignKeysInEditions < ActiveRecord::Migration[5.2]
  def change
    add_index :editions, :author_id unless index_exists?(:editions, :author_id)
    add_index :editions, :content_owner_id unless index_exists?(:editions, :content_owner_id)
    add_index :editions, :guide_id unless index_exists?(:editions, :guide_id)
  end
end
