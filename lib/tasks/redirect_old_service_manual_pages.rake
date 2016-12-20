desc "This is a one off task to redirect pages in the old service manual to GOV.UK"
task redirect_old_service_manual_pages: :environment do
  redirects = {
    "/service-manual/feedback" => "/contact/govuk ",
    "/service-manual/feedback/index" => "/contact/govuk",
    "/service-manual/about.html" => "/service-manual",
    "/service-manual/agile/spending-controls.html" => "/service-manual/agile-delivery/spend-controls-check-if-you-need-approval-to-spend-money-on-a-service",
    "/service-manual/agile/spending-controls" => "/service-manual/agile-delivery/spend-controls-check-if-you-need-approval-to-spend-money-on-a-service",
    "/service-manual/making-software/open-source" => "/service-manual/technology/choosing-technology-an-introduction",
    "/service-manual/making-software/open-source.html" => "/service-manual/technology/choosing-technology-an-introduction",
    "/service-manual/measurement/completionrate.html" => "/service-manual/measuring-success/measuring-completion-rate",
    "/service-manual/measurement/costpertransaction.html" => "/service-manual/measuring-success/measuring-completion-rate",
    "/service-manual/measurement/performanceframework.html" => "/service-manual/measuring-success/using-data-to-improve-your-service-an-introduction",
    "/service-manual/measurement/performance-framework.html" => "/service-manual/measuring-success/using-data-to-improve-your-service-an-introduction",
    "/service-manual/measurement/performance-framework" => "/service-manual/measuring-success/using-data-to-improve-your-service-an-introduction",
    "/service-manual/measurement/usersatisfaction.html" => "/service-manual/measuring-success/measuring-user-satisfaction",
    "/service-manual/digital-by-default/providing-evidence.html" => "/service-manual",
    "/service-manual/the-team/transformation-partner.html" => "/service-manual/the-team/working-contractors-third-parties",
    "/service-manual/users/user-research/communityusergroups.html" => "/service-manual/user-research",
    "/service-manual/users/user-research/discussionguides.html" => "/service-manual/user-research",
    "/service-manual/users/user-research/ethnographicresearch.html" => "/service-manual/user-research",
    "/service-manual/users/user-research/expertreview.html" => "/service-manual/user-research",
    "/service-manual/users/user-research/focusgroupsminigroupsandinterviews.html" => "/service-manual/user-research",
    "/service-manual/users/user-research/guerillatesting.html" => "/service-manual/user-research",
    "/service-manual/users/user-research/labbasedusertesting.html" => "/service-manual/user-research",
    "/service-manual/users/user-research/multivariatetesting.html" => "/service-manual/user-research",
    "/service-manual/users/user-research/onlineomnibussurvey.html" => "/service-manual/user-research",
    "/service-manual/users/user-research/onlineresearchpanels.html" => "/service-manual/user-research",
    "/service-manual/users/user-research/remoteusability.html" => "/service-manual/user-research",
    "/service-manual/users/user-research/samedayusertesting.html" => "/service-manual/user-research",
    "/service-manual/users/user-research/samplingmethodologies.html" => "/service-manual/user-research",
    "/service-manual/users/user-research/sentimentanalysis.html" => "/service-manual/user-research",
    "/service-manual/users/user-research/surveydesign.html" => "/service-manual/user-research",
    "/service-manual/users/user-research/userresearchbriefs.html" => "/service-manual/user-research/write-a-recruitment-brief",
    "/service-manual/users/user-research/userresearchsurveys.html" => "/service-manual/user-research",
    "/service-manual/users/user-research/userresearchtools.html" => "/service-manual/user-research",
    "/service-manual/the-team/content-designer-jd.html" => "/service-manual/the-team/what-each-role-does-in-service-team",
    "/service-manual/the-team/delivery-manager-jd.html" => "/service-manual/the-team/what-each-role-does-in-service-team",
    "/service-manual/the-team/designer-jd.html" => "/service-manual/the-team/what-each-role-does-in-service-team",
    "/service-manual/the-team/developer-jd.html" => "/service-manual/the-team/what-each-role-does-in-service-team",
    "/service-manual/the-team/performance-analyst-jd.html" => "/service-manual/the-team/what-each-role-does-in-service-team",
    "/service-manual/the-team/service-manager-jd.html" => "/service-manual/the-team/what-each-role-does-in-service-team",
    "/service-manual/the-team/user-researcher-jd.html" => "/service-manual/the-team/what-each-role-does-in-service-team",
    "/service-manual/the-team/web-operations-jd.html" => "/service-manual/the-team/what-each-role-does-in-service-team",
    "/service-manual/the-team/recruitment/content-designer-jd" => "/service-manual/the-team/what-each-role-does-in-service-team",
    "/service-manual/the-team/recruitment/delivery-manager-jd" => "/service-manual/the-team/what-each-role-does-in-service-team",
    "/service-manual/the-team/recruitment/designer-jd.html" => "/service-manual/the-team/what-each-role-does-in-service-team",
    "/service-manual/the-team/recruitment/developer-jd" => "/service-manual/the-team/what-each-role-does-in-service-team",
    "/service-manual/the-team/recruitment/performance-analyst-jd" => "/service-manual/the-team/what-each-role-does-in-service-team",
    "/service-manual/the-team/recruitment/service-manager-jd" => "/service-manual/the-team/what-each-role-does-in-service-team",
    "/service-manual/the-team/recruitment/user-researcher-jd" => "/service-manual/the-team/what-each-role-does-in-service-team",
    "/service-manual/the-team/recruitment/web-operations-jd" => "/service-manual/the-team/what-each-role-does-in-service-team",
    "/service-manual/design-and-content" => "/service-manual/design",
    "/service-manual/users" => "/service-manual/design"
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
