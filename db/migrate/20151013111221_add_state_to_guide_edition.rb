class AddStateToGuideEdition < ActiveRecord::Migration
  def change
    add_column :guide_editions, :state, :text
  end
end
