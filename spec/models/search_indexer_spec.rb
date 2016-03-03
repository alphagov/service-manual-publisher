require 'rails_helper'

RSpec.describe SearchIndexer do
  it "indexes documents in rummager" do
    index = double(:rummageable_index)
    plek = Plek.current.find('rummager')
    expect(Rummageable::Index).to receive(:new).with(plek, "/service-manual").and_return index
    guide = build_stubbed(:guide, slug: "/service-manual/some-slug")
    expect(index).to receive(:add_batch).with([{
      _type:             "manual_section",
      description:       guide.latest_edition.description,
      indexable_content: guide.latest_edition.body,
      title:             guide.latest_edition.title,
      link:              guide.slug,
      manual:            "service-manual",
      organisations:     ["government-digital-service"]
    }])
    SearchIndexer.new(guide).index
  end
end
