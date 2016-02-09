class AddContentIdToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :content_id, :string
    add_index :topics, :content_id

    Topic.all.each do |topic|
      topic.update_attribute(:content_id, SecureRandom.uuid)
    end
  end
end
