desc "Print the change history for all published guides"
task print_change_history_for_published_guides: :environment do
  Guide.live.find_each do |guide|
    editions = guide.editions.published.major
    if editions.any?
      puts "## #{guide.title}"
      puts guide.slug
      puts ""

      editions.each do |edition|
        puts "### #{edition.updated_at.to_formatted_s}"
        puts "Change note: '#{edition.change_note}'"
        puts ""
      end

      puts ""
    end
  end
end
