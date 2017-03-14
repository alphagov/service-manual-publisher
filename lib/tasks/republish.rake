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

  desc "republish homepage"
  task homepage: :environment do
    homepage = HomepagePresenter.new

    # Save a draft of the homepage
    puts "Republishing homepage..."
    PUBLISHING_API.put_content(homepage.content_id, homepage.content_payload)
    PUBLISHING_API.publish(homepage.content_id, "minor")
  end
end
