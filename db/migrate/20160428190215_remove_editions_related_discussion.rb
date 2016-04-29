class RemoveEditionsRelatedDiscussion < ActiveRecord::Migration
  def change
    remove_column :editions, :related_discussion_href
    remove_column :editions, :related_discussion_title
  end
end
