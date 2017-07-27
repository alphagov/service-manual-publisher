require 'rails_helper'

RSpec.describe GuideRepublisher, "#republish" do
  it "saves the content, links and publishes" do
    publishing_api = double(:publishing_api)
    guide = create(:guide, :with_published_edition, slug: "/service-manual/topic/guide")

    expect(publishing_api).to receive(:put_content)
      .with(guide.content_id, hash_including(base_path: "/service-manual/topic/guide"))
    expect(publishing_api).to receive(:patch_links)
      .with(guide.content_id, hash_including(links: kind_of(Hash)))
    expect(publishing_api).to receive(:publish).with(guide.content_id, "minor")

    described_class.new(guide, publishing_api: publishing_api).republish
  end

  it "does not attempt to publish anything if there isn't a live editon" do
    publishing_api = double(:publishing_api)
    guide = create(:guide)

    expect(publishing_api).to_not receive(:put_content)
    expect(publishing_api).to_not receive(:put_links)
    expect(publishing_api).to_not receive(:publish)

    described_class.new(guide, publishing_api: publishing_api).republish
  end

  it 'always republishes as a minor edition' do
    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links
    stub_any_publishing_api_publish

    guide = create(:guide, :with_published_edition, edition: { update_type: "major" })

    described_class.new(guide).republish

    assert_publishing_api_publish(guide.content_id, update_type: "minor")
  end
end
