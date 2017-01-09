task migrate_change_notes: :environment do
  edition_id = Edition.published.take.id
  migrator = ChangeNoteMigrator.new(dry_run: !ENV.key?('PERFORM_AGAINST_DATABASE_AND_PUBLISHING_API'))

  # migrator.update_change_note(edition_id, change_note)
  # migrator.make_minor(edition_id)
  # migrator.make_major(edition_id, change_note)
end
