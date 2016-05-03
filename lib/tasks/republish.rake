namespace :republish do
  desc "republish all guides"
  task guides: :environment do
    Guide.find_each do |guide|
      GuideRepublisher.new(guide).republish
    end
  end
end
