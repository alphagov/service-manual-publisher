class MoveTopicTreeToSql < ActiveRecord::Migration
  def up
    Topic.all.each do |topic|
      Array(topic.tree).each_with_index do |item, _index|
        topic_section = topic.topic_sections.create!(
          title:       item["title"],
          description: item["description"],
        )

        Guide.where(id: item["guides"]).each do |guide|
          topic_section.guides << guide
        end
      end
    end
  end

  def down; end
end
