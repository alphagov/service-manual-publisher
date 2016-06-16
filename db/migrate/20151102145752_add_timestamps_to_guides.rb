class AddTimestampsToGuides < ActiveRecord::Migration
  def up
    change_table :guides, &:timestamps

    Guide.all.each do |guide|
      if guide.latest_edition
        guide.update_columns(created_at: guide.latest_edition.created_at, updated_at: guide.latest_edition.updated_at)
      else
        guide.touch(:created_at, :updated_at)
      end
    end
  end

  def down
    remove_column :guides, :created_at
    remove_column :guides, :updated_at
  end
end
