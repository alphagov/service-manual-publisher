class DropContentOwnersTopics < ActiveRecord::Migration
  def change
    drop_table :content_owners_topics
  end
end
