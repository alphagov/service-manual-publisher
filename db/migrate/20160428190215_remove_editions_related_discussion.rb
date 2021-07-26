class RemoveEditionsRelatedDiscussion < ActiveRecord::Migration[5.2]
  def change
    remove_column :editions, :related_discussion_href
    remove_column :editions, :related_discussion_title
  end
end
