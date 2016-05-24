desc "Delete the duplicated technology topic"
task delete_duplicated_technology_topic: :environment do
  topic = Topic.find_by(id: 16, path: "/service-manual/technology")
  if topic && topic.topic_sections.empty?
    topic.destroy
  end
end
