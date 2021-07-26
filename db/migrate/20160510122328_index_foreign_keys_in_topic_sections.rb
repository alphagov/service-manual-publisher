class IndexForeignKeysInTopicSections < ActiveRecord::Migration[5.2]
  def change
    add_index :topic_sections, :topic_id
  end
end
