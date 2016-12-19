desc "This is a one off task to redirect pages in the old service manual to GOV.UK"
task redirect_old_service_manual_pages: :environment do
  redirects = {
    "/service-manual/user-centred-design/how-users-read" => "/guidance/content-design/writing-for-gov-uk#how-people-read",
    "/service-manual/user-centred-design/how-users-read.html" => "/guidance/content-design/writing-for-gov-uk#how-people-read",
    "/service-manual/user-centred-design/resources/creating-accessible-PDFs" => "/guidance/how-to-publish-on-gov-uk/accessible-pdfs",
    "/service-manual/user-centred-design/resources/creating-accessible-PDFs.html" => "/guidance/how-to-publish-on-gov-uk/accessible-pdfs",
    "/service-manual/user-centred-design/choosing-appropriate-formats" => "/guidance/content-design/planning-content#open-formats",
    "/service-manual/user-centred-design/choosing-appropriate-formats.html" => "/guidance/content-design/planning-content#open-formats"
  }

  redirects.each do |old_path, new_path|
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
