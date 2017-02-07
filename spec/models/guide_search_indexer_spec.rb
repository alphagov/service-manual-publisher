require 'rails_helper'

RSpec.describe GuideSearchIndexer, '#index' do
  before do
    stub_any_rummager_post
  end

  it 'indexes a document in rummager for the live edition' do
    guide = create(:guide, :with_published_edition,
                    title: 'My guide',
                    body: "It's my published guide content",
                    slug: '/service-manual/topic/some-slug'
                  )
    guide.editions << build(:edition, body: "I'm reconsidering this draft..")

    described_class.new(guide).index

    assert_rummager_posted_item(
      _type:             'service_manual_guide',
      _id:               '/service-manual/topic/some-slug',
      format:            'service_manual_guide',
      content_store_document_type: "service_manual_guide",
      description:       'Description',
      indexable_content: "It's my published guide content",
      title:             'My guide',
      link:              '/service-manual/topic/some-slug',
      manual:            '/service-manual',
      organisations:     ['government-digital-service'],
    )
  end

  it 'does not attempt to index a guide if it has no live editions' do
    guide = create(:guide)

    described_class.new(guide).index

    assert_not_requested(
      :post,
      %r{#{GdsApi::TestHelpers::Rummager::RUMMAGER_ENDPOINT}/documents}
    )
  end
end

RSpec.describe GuideSearchIndexer, '#delete' do
  it 'deletes documents from rummager' do
    stub_any_rummager_delete_content
    guide = create(:guide, :with_draft_edition, slug: '/service-manual/topic/some-slug')

    described_class.new(guide).delete

    assert_rummager_deleted_content '/service-manual/topic/some-slug'
  end
end
