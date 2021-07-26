class RemoveTopicTree < ActiveRecord::Migration[5.2]
  def change
    remove_column :topics, :tree, :json
  end
end
