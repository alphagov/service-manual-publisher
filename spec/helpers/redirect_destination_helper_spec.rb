require 'rails_helper'

RSpec.describe RedirectDestinationHelper, '#redirect_destination_select_options', type: :helper do
  it 'should return all available slugs' do
    topic = create(:topic)
    create(:guide, :has_been_unpublished, topic: topic)
    guide = create(:guide, :with_published_edition, topic: topic)

    expect(helper.redirect_destination_select_options).to match(
      "Other" => ["/service-manual", "/service-manual/service-standard"],
      "Topics" => include(topic.path),
      "Guides" => [guide.slug]
    )
  end
end
