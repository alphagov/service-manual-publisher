require 'rails_helper'

RSpec.describe GuideRepublisher, '#republish' do
  it 'republishes all guides' do
    publishing_api = double(:publishing_api)
    guide1 = create(:guide)
    guide2 = create(:guide)

    expect_guide_to_be_republished(guide1, publishing_api)
    expect_guide_to_be_republished(guide2, publishing_api)

    republisher = described_class.new([guide1, guide2], publishing_api: publishing_api)
    republisher.republish
  end

  it 'writes to the supplied logger' do
    log = Tempfile.new('simulated-log')
    publishing_api = double(:publishing_api)
    guide1 = create(:guide)

    expect_guide_to_be_republished(guide1, publishing_api)

    republisher = described_class.new([guide1], publishing_api: publishing_api, logger: log)
    republisher.republish

    expect_log_contains(log, "Republishing: #{guide1.title}\n")
  end

  def expect_guide_to_be_republished(guide, publishing_api)
    expect(publishing_api).to receive(:put_content).
                              with(guide.content_id, a_hash_including(base_path: guide.slug))
    expect(publishing_api).to receive(:patch_links).
                              with(guide.content_id, a_kind_of(Hash))
    expect(publishing_api).to receive(:publish).
                              with(guide.content_id, guide.latest_edition.update_type)
  end

  def expect_log_contains(log, string)
    log.rewind
    expect(log.readlines).to include(string)
  end
end
