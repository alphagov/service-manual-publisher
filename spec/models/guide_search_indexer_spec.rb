require 'rails_helper'

RSpec.describe GuideSearchIndexer, "#index" do
  it "indexes a document in rummager for the live edition" do
    rummager_api = double(:rummager_api)
    guide = create(:published_guide,
                    title: "My guide",
                    body: "It's my published guide content",
                    slug: "/service-manual/topic/some-slug"
                  )
    guide.editions << build(:edition, body: "I'm reconsidering this draft..")

    expect(rummager_api).to receive(:add_document).with(
      "service_manual_guide",
      "/service-manual/topic/some-slug",
      format:            "service_manual_guide",
      description:       "Description",
      indexable_content: "It's my published guide content",
      title:             "My guide",
      link:              "/service-manual/topic/some-slug",
      manual:            "/service-manual",
      organisations:     ["government-digital-service"],
    )

    described_class.new(guide, rummager_api: rummager_api).index
  end

  it "does not attempt to index a guide if it has no live editons" do
    rummager_api = double(:rummager_api)
    guide = create(:guide)

    expect(rummager_api).to_not receive(:add_document)

    described_class.new(guide, rummager_api: rummager_api).index
  end
end

RSpec.describe GuideSearchIndexer, "#delete" do
  it "deletes documents from rummager" do
    rummager_api = double(:rummager_api)
    guide = create(:guide, :with_draft_edition, slug: "/service-manual/topic/some-slug")

    expect(rummager_api).to receive(:delete_content!).with("/service-manual/topic/some-slug")

    described_class.new(guide, rummager_api: rummager_api).delete
  end
end
