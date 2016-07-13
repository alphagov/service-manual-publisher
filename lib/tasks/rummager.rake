namespace :rummager do
  desc "index all published documents in rummager"
  task index: :environment do
    Guide.all.each do |guide|
      puts "Indexing #{guide.title}..."

      GuideSearchIndexer.new(guide).index
    end

    Rake::Task['rummager:index_service_standard'].execute
  end

  desc 'index the service standard in rummager'
  task index_service_standard: :environment do
    puts "Indexing Service Standard..."

    ServiceStandardSearchIndexer.new.index
  end

  desc "A temporary task to delete some unpublished documents from rummager " \
    "which failed due to a bug"
  task delete_failed: :environment do
    guide_slugs = %w(
      /service-manual/agile-delivery/check-if-you-need-to-spend-money-on-a-service
      /service-manual/spending-money-on-your-service/apply-for-approval-to-spend-money-on-a-service
      /service-manual/spending-money-on-your-service/check-if-you-need-approval-to-spend-money-on-a-service
      /service-manual/agile-delivery-community
      /service-manual/digital-foundation-day-training
    )
    Guide.where(slug: guide_slugs).each do |guide|
      begin
        GuideSearchIndexer.new(guide).delete
      rescue => e
        puts "Guide failed: #{guide.slug}"
        puts e.inspect
        puts e.backtrace.join("\n")
      end
    end
  end
end
