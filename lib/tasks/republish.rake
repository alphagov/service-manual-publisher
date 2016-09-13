namespace :republish do
  desc "republish all guides"
  task guides: :environment do
    Guide.find_each do |guide|
      puts "Republishing #{guide.title}..."

      GuideRepublisher.new(guide).republish
    end
  end

  desc "republish all topics"
  task topics: :environment do
    Topic.find_each do |topic|
      puts "Republishing #{topic.title}..."

      publisher = TopicPublisher.new(topic: topic)
      publisher.save_draft
      publisher.publish
    end
  end
end
