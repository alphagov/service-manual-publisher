desc "Print out guide details"
task print_guide_details: :environment do
  Guide.live.find_each do |guide|
    editions = guide.editions

    puts "Guide: #{guide.title}, slug: '#{guide.slug}'"
    editions.published.major.each do |edition|
      puts "Edition details:"
      puts "Change note: '#{edition.change_note}'"
      puts "Reason for change: '#{edition.reason_for_change}'"
      puts ""
    end
    puts "---------------------------"
  end

end
