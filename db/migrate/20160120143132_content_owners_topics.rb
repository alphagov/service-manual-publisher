class ContentOwnersTopics < ActiveRecord::Migration
  def change
    create_table :content_owners_topics do |t|
      t.references :content_owner, index: true
      t.references :topic, index: true
      t.timestamps
    end
  end
end
