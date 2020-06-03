require "highline"

namespace :republish do
  desc "republish all guides"
  task guides: :environment do
    Guide.live.find_each do |guide|
      puts "Republishing #{guide.title}..."
      presenter = GuidePresenter.new(guide, guide.live_edition)
      Republisher.new.call(presenter)
    end
  end

  desc "republish all topics, including drafts"
  task topics: :environment do
    Topic.find_each do |topic|
      puts "Republishing #{topic.title}..."
      presenter = TopicPresenter.new(topic)
      Republisher.new.call(presenter)
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
