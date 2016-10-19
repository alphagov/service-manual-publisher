desc "Remove orphaned topic section guide associations"
task remove_orphaned_topic_section_guides: :environment do
  puts "Removing orphaned associations..."

  TopicSectionGuide.where([
    "guide_id NOT IN (?)",
    Guide.pluck("id")
  ]).destroy_all

  puts "Done."
end
