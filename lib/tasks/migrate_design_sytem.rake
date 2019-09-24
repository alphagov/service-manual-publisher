redirects = {
  "/service-manual/design/using-the-govuk-template-frontend-toolkit-and-elements" => "https://design-system.service.gov.uk",
  "/service-manual/design/add-the-govuk-header-and-footer" => "https://design-system.service.gov.uk/styles/page-template/",
  "/service-manual/design/addresses" => "https://design-system.service.gov.uk/patterns/addresses/",
  "/service-manual/design/alpha-and-beta-phase-banners" => "https://design-system.service.gov.uk/components/phase-banner/",
  "/service-manual/design/check-before-you-start" => "https://design-system.service.gov.uk/patterns/check-a-service-is-suitable/",
  "/service-manual/design/check-your-answers-pages" => "https://design-system.service.gov.uk/patterns/check-answers/",
  "/service-manual/design/confirmation-pages" => "https://design-system.service.gov.uk/patterns/confirmation-pages/",
  "/service-manual/design/dates" => "https://design-system.service.gov.uk/patterns/dates/",
  "/service-manual/design/email-addresses" => "https://design-system.service.gov.uk/patterns/email-addresses/",
  "/service-manual/design/email-confirmation-loops" => "https://design-system.service.gov.uk/patterns/confirm-an-email-address/",
  "/service-manual/design/gender-or-sex" => "https://design-system.service.gov.uk/patterns/gender-or-sex/",
  "/service-manual/design/names" => "https://design-system.service.gov.uk/patterns/names/",
  "/service-manual/design/national-insurance-numbers" => "https://design-system.service.gov.uk/patterns/national-insurance-numbers/",
  "/service-manual/design/passwords" => "https://design-system.service.gov.uk/patterns/passwords/",
  "/service-manual/design/progress-indicators" => "https://design-system.service.gov.uk/patterns/question-pages#progress-indicators",
  "/service-manual/design/question-pages" => "https://design-system.service.gov.uk/patterns/question-pages/",
  "/service-manual/design/start-pages" => "https://design-system.service.gov.uk/patterns/start-pages/",
  "/service-manual/design/task-list-pages-beta" => "https://design-system.service.gov.uk/patterns/task-list-pages/",
  "/service-manual/design/user-accounts" => "https://design-system.service.gov.uk/patterns/create-accounts/",
  "/service-manual/design/usernames" => "https://design-system.service.gov.uk/patterns/create-a-username/",
}

# rubocop:disable Metrics/BlockLength
desc "Migrate design patterns to the design system"
task migrate_design_system: :environment do
  unless ENV.key?("USER_ID")
    puts "Must specify a USER_ID"
    exit 1
  end

  user = User.find(ENV["USER_ID"])
  unless user
    puts "Invalid user #{ENV['USER_ID']}"
    exit 1
  end

  puts "Making changes as #{user.name} (#{user.email})"

  redirects.each do |source, destination|
    puts "Redirecting from #{source} to #{destination}..."
    guide = Guide.find_by_slug(source)

    if guide
      puts "\tFound #{guide.title}..."
    else
      puts "\tGuide not found"
      next
    end

    guide_manager = GuideManager.new(guide: guide, user: user)
    result = guide_manager.unpublish_with_redirect(destination)

    if result.success?
      puts "\tRedirect created"
    else
      puts "\tFailed to publish redirect"
      puts result.errors
    end
    puts "Done."
  end
end
# rubocop:enable Metrics/BlockLength
