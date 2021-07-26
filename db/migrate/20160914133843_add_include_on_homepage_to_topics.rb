class AddIncludeOnHomepageToTopics < ActiveRecord::Migration[5.2]
  def change
    add_column :topics, :include_on_homepage, :boolean, default: true
  end
end
