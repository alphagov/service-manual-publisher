desc "Republish all guides"
task republish_all_guides: :environment do
  GuideRepublisher.new(Guide.with_published_editions).
                   republish
end
