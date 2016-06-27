require 'rails_helper'

RSpec.describe SlugMigrationsHelper, '#select_options', type: :helper do
  it 'should return all available slugs' do
    guide = create(:published_guide)
    topic = create(:topic)

    expect(helper.select_options).to eq(
      "Other" => ["/service-manual", "/service-manual/service-standard"],
      "Topics" => [[topic.path, topic.path]],
      "Guides" => [[guide.slug, guide.slug]]
    )
  end
end
