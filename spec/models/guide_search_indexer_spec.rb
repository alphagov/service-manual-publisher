require 'rails_helper'

RSpec.describe GuideSearchIndexer, "#index" do
  it "indexes a document in rummager for the most recently published edition" do
    rummager_index = double(:rummageable_index)
    guide = create(:published_guide,
                    title: "My guide",
                    body: "It's my published guide content",
                    slug: "/service-manual/topic/some-slug"
                    )
    guide.editions << build(:edition, body: "I'm reconsidering this draft..")

    expect(rummager_index).to receive(:add_batch).with([{
      format:            "service_manual_guide",
      _type:             "service_manual_guide",
      description:       "Description",
      indexable_content: "It's my published guide content",
      title:             "My guide",
      link:              "/service-manual/topic/some-slug",
      manual:            "service-manual",
      organisations:     ["government-digital-service"]
    }])

    described_class.new(guide, rummager_index: rummager_index).index
  end
end

RSpec.describe GuideSearchIndexer, "#delete" do
  it "deletes documents from rummager" do
    rummager_index = double(:rummageable_index)
    guide = create(:guide, :with_draft_edition, slug: "/service-manual/topic/some-slug")

    expect(rummager_index).to receive(:delete).with("/service-manual/topic/some-slug")

    described_class.new(guide, rummager_index: rummager_index).delete
  end
end
