desc "This is a one off task to redirect tech code of practise"
task redirect_tech_code_of_practise: :environment do
  old_paths = [
    "/service-manual/technology/code-of-practice.html",
    "/service-manual/technology/code-of-practice",
  ]
  new_path = "/government/publications/technology-code-of-practice/technology-code-of-practice"

  old_paths.each do |old_path|
    # Mark the SlugMigration as migrated

    slug_migration = SlugMigration.find_by!(slug: old_path)
    slug_migration.update!(
      completed: true,
      redirect_to: new_path,
    )

    # Publish a redirect to the publishing platform

    RedirectPublisher.new.process(
      content_id: slug_migration.content_id,
      old_path:   slug_migration.slug,
      new_path:   slug_migration.redirect_to,
    )
  end
end
