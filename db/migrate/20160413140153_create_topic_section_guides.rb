class CreateTopicSectionGuides < ActiveRecord::Migration
  def change
    create_table :topic_section_guides do |t|
      t.integer :topic_section_id, null: false
      t.integer :guide_id, null: false
      t.integer :position, null: false
      t.timestamps
    end
  end
end
