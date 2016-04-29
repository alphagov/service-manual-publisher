namespace :rummager do
  desc "Index all live guides in rummager"
  task index_guides: :environment do
    Guide.all.each do |guide|
      puts "Indexing #{guide.title}..."

      GuideSearchIndexer.new(guide).index
    end
  end

  # WARNING: This indexes topics whether they have been published or not.
  # We don't currently store the state of a Topic so this is best we can do
  # at the moment. Rather than using this rake task it is safer to republish
  # each topic manually.
  desc "Index published AND unpublished topics in rummager"
  task index_topics: :environment do
    Topic.all.each do |guide|
      puts "Indexing #{topic.title}..."

      TopicSearchIndexer.new(topic).index
    end
  end

  desc "Index all content"
  task index_all: [:index_guides, :index_topics]
end
