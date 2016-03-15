namespace :rummager do
  desc "index all published documents in rummager"
  task index: :environment do
    Guide.all.each do |guide|
      puts "Indexing #{guide.title}..."

      SearchIndexer.new(guide).index
    end
  end
end
