task make_first_editions_major: :environment do
  migrator = ChangeNoteMigrator.new(
    dry_run: !ENV.key?("PERFORM_AGAINST_DATABASE_AND_PUBLISHING_API"),
  )

  cli = HighLine.new

  Guide.find_each do |guide|
    cli.say guide.slug

    changes_made = false
    guide.editions.published.where(version: 1, update_type: "minor").each do |edition|
      changes_made = true
      migrator.make_major(edition.id, "Guidance first published")
    end

    cli.say cli.color("  No changes...", :red) unless changes_made

    cli.say "\n"
  end
end
