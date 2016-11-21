require 'rails_helper'

RSpec.describe RedirectDestinationHelper, '#redirect_destination_select_options', type: :helper do
  it 'should include all published guides ordered by slug' do
    create(:guide, :with_published_edition,
      slug: "/service-manual/agile-delivery/team-wall"
    )
    create(:guide, :with_published_edition,
      slug: "/service-manual/agile-delivery/core-principles-agile"
    )

    create(:guide, :has_been_unpublished)
    create(:guide, :with_draft_edition)

    expect(helper.redirect_destination_select_options).to include(
      "Guides" => [
        "/service-manual/agile-delivery/core-principles-agile",
        "/service-manual/agile-delivery/team-wall"
      ]
    )
  end

  it 'should include the homepage and the service standard' do
    expect(helper.redirect_destination_select_options).to include(
      "Other" => ["/service-manual", "/service-manual/service-standard"],
    )
  end

  it 'should include all topics' do
    create(:topic, path: "/service-manual/agile-delivery")

    expect(helper.redirect_destination_select_options).to include(
      "Topics" => ["/service-manual/agile-delivery"]
    )
  end
end
