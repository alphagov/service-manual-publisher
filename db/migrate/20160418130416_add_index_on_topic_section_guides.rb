class AddIndexOnTopicSectionGuides < ActiveRecord::Migration[5.2]
  def change
    add_index :topic_section_guides, :topic_section_id
    add_index :topic_section_guides, :guide_id
  end
end
