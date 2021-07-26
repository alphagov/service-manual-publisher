class DropContentOwnersTopics < ActiveRecord::Migration[5.2]
  def change
    drop_table :content_owners_topics
  end
end
