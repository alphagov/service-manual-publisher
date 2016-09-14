class AddIncludeOnHomepageToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :include_on_homepage, :boolean, default: true
  end
end
