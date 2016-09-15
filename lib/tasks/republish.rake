require 'highline'

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
    cli = HighLine.new
    cli.say cli.color(
      "This will publish the latest revision of all topics, even if they have not previously been published.",
      :red
    )
    exit unless cli.agree "Are you sure you wish to continue?"

    Topic.find_each do |topic|
      puts "Republishing #{topic.title}..."

      publisher = TopicPublisher.new(topic: topic)
      publisher.save_draft
      publisher.publish
    end
  end
end
