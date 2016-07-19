require 'rails_helper'

RSpec.describe RedirectDestinationHelper, '#redirect_destination_select_options', type: :helper do
  it 'should return all available slugs' do
    create(:guide, :has_been_unpublished)
    guide = create(:guide, :with_published_edition)
    topic = create(:topic)

    expect(helper.redirect_destination_select_options).to eq(
      "Other" => ["/service-manual", "/service-manual/service-standard"],
      "Topics" => [[topic.path, topic.path]],
      "Guides" => [[guide.slug, guide.slug]]
    )
  end
end
