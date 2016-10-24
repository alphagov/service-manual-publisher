desc "Print out guide details"
task print_guide_details: :environment do
  Guide.live.find_each do |guide|
    editions = guide.editions.published.major
    if editions.any?
      puts "## #{guide.title}"
      puts "#{guide.slug}"
      puts ""

      editions.each do |edition|
        puts "### #{edition.updated_at.to_formatted_s}"
        puts "Change note: '#{edition.change_note}'"
        puts "Reason for change: '#{edition.reason_for_change}'"
        puts ""
      end

      puts ""
    end
  end

end
