require 'rails_helper'

RSpec.describe SearchIndexer, "#index" do
  it "indexes a document in rummager for the most recently published edition" do
    index = double(:rummageable_index)
    plek = Plek.current.find('rummager')

    guide = create(:published_guide,
                    title: "My guide",
                    body: "It's my published guide content",
                    slug: "/service-manual/topic/some-slug"
                    )
    guide.editions << build(:edition, body: "I'm reconsidering this draft..")

    expect(Rummageable::Index).to receive(:new).with(plek, "/mainstream").and_return index
    expect(index).to receive(:add_batch).with([{
      format:            "service_manual_guide",
      _type:             "service_manual_guide",
      description:       "Description",
      indexable_content: "It's my published guide content",
      title:             "My guide",
      link:              "/service-manual/topic/some-slug",
      manual:            "service-manual",
      organisations:     ["government-digital-service"]
    }])

    SearchIndexer.new(guide).index
  end
end

RSpec.describe SearchIndexer, "#delete" do
  it "deletes documents from rummager" do
    index = double(:rummageable_index)
    plek = Plek.current.find('rummager')
    expect(Rummageable::Index).to receive(:new).with(plek, "/mainstream").and_return index
    guide = create(:guide, :with_draft_edition, slug: "/service-manual/topic/some-slug")
    expect(index).to receive(:delete).with(guide.slug)
    SearchIndexer.new(guide).delete
  end
end
