class RemoveTopicTree < ActiveRecord::Migration
  def change
    remove_column :topics, :tree, :json
  end
end
