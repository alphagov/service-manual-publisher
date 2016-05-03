require 'rails_helper'

RSpec.describe GuideRepublisher, "#republish" do
  it "saves the content, links and publishes" do
    publishing_api = double(:publishing_api)
    guide = create(:published_guide, slug: "/service-manual/topic/guide")

    expect(publishing_api).to receive(:put_content)
                                .with(guide.content_id, hash_including(base_path: "/service-manual/topic/guide"))
    expect(publishing_api).to receive(:patch_links)
                                .with(guide.content_id, hash_including(links: kind_of(Hash)))
    expect(publishing_api).to receive(:publish).with(guide.content_id, "major")

    described_class.new(guide, publishing_api: publishing_api).republish
  end
end
