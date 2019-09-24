require "rails_helper"

RSpec.describe RedirectDestinationHelper, "#redirect_destination_select_options", type: :helper do
  it "should include all published guides ordered by slug" do
    create(:guide, :with_published_edition,
           slug: "/service-manual/agile-delivery/team-wall")
    create(:guide, :with_published_edition,
           slug: "/service-manual/agile-delivery/core-principles-agile")

    create(:guide, :has_been_unpublished)
    create(:guide, :with_draft_edition)

    expect(helper.redirect_destination_select_options).to include(
      "Guides" => [
        "/service-manual/agile-delivery/core-principles-agile",
        "/service-manual/agile-delivery/team-wall",
      ],
    )
  end

  it "should include the homepage and the service standard" do
    expect(helper.redirect_destination_select_options).to include(
      "Other" => ["/service-manual", "/service-manual/service-standard"],
    )
  end

  it "should include all topics with sub sections" do
    topic = create(:topic, path: "/service-manual/agile-delivery")
    create(:topic_section, title: "Working with agile methods", topic: topic)
    create(:topic_section, title: "Governing agile services", topic: topic)

    expect(helper.redirect_destination_select_options).to include(
      "Topics" => [
        "/service-manual/agile-delivery",
        ["/service-manual/agile-delivery → Governing agile services", "/service-manual/agile-delivery#governing-agile-services"],
        ["/service-manual/agile-delivery → Working with agile methods", "/service-manual/agile-delivery#working-with-agile-methods"],
      ],
    )
  end

  it "should exclude topic sections without titles" do
    topic = create(:topic, path: "/service-manual/agile-delivery")
    create(:topic_section, title: "", topic: topic)

    expect(helper.redirect_destination_select_options).to include(
      "Topics" => ["/service-manual/agile-delivery"],
    )
  end
end
