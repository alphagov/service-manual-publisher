namespace :rummager do
  desc "index all published documents in rummager"
  task index: :environment do
    require 'plek'
    require 'rummageable'

    root_document = {
      format: "service_manual",
      title: "Government Service Design Manual",
      description: "All new digital services from the government must meet the Digital by Default Service Standard",
      link: "/service-manual",
      organisations: "government-digital-service",
    }
    index_document root_document

    Guide.all.each do |guide|
      edition = guide.latest_edition
      if edition.published?
        puts "Indexing #{edition.title}..."
        index_document({
          "format": "service_manual",
          "_type": "service_manual",
          "description": edition.description,
          "indexable_content": edition.body,
          "title": edition.title,
          "link": guide.slug,
          "manual": "/service-manual",
          "organisations": [ "government-digital-service" ],
        })
      end
    end
  end

  def index_document document
    @rummageable_index ||= Rummageable::Index.new(
      Plek.current.find('rummager'), '/mainstream'
    )
    @rummageable_index.add_batch([document])
  end
end
