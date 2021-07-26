class AddContentIdToTopics < ActiveRecord::Migration[5.2]
  def change
    add_column :topics, :content_id, :string
    add_index :topics, :content_id

    Topic.all.each do |topic|
      topic.update_attribute(:content_id, SecureRandom.uuid)
    end
  end
end
