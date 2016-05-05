namespace :republish do
  desc "republish all guides"
  task guides: :environment do
    Guide.find_each do |guide|
      puts "Republishing #{guide.title}..."

      GuideRepublisher.new(guide).republish
    end
  end
end
