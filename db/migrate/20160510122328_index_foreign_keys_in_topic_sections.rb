class IndexForeignKeysInTopicSections < ActiveRecord::Migration
  def change
    add_index :topic_sections, :topic_id
  end
end
