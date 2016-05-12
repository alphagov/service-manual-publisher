class IndexForeignKeysInGuides < ActiveRecord::Migration
  def change
    add_index :guides, :content_id
  end
end
