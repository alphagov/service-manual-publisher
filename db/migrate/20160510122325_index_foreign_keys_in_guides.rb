class IndexForeignKeysInGuides < ActiveRecord::Migration[5.2]
  def change
    add_index :guides, :content_id
  end
end
