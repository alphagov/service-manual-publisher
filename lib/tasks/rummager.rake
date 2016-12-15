namespace :rummager do
  desc "index all guides, topics and the service standard in Rummager"
  task index: [:index_guides, :index_topics, :index_service_standard, :index_homepage]

  desc 'Index all guides in Rummager'
  task index_guides: :environment do
    Guide.all.each do |guide|
      puts "Indexing guide #{guide.title}..."

      GuideSearchIndexer.new(guide).index
    end
  end

  desc 'Index all topics in Rummager'
  task index_topics: :environment do
    Topic.all.each do |topic|
      puts "Indexing topic #{topic.title}..."

      TopicSearchIndexer.new(topic).index
    end
  end

  desc 'Index the service standard in Rummager'
  task index_service_standard: :environment do
    puts "Indexing the Service Standard..."

    ServiceStandardSearchIndexer.new.index
  end

  desc 'Index the homepage in Rummager'
  task index_homepage: :environment do
    puts "Indexing the Homepage..."

    HomepageSearchIndexer.new.index
  end
end
