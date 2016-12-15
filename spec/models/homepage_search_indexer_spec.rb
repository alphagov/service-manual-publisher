require 'rails_helper'

RSpec.describe HomepageSearchIndexer, '#index' do
  it 'indexes a document in rummager' do
    stub_any_rummager_post

    described_class.new.index

    assert_rummager_posted_item(
      _type:              'service_manual_guide',
      _id:                '/service-manual',
      format:             'service_manual_guide',
      description:        'Helping government teams create and run great digital services that meet the Digital Service Standard.',
      indexable_content:  '',
      title:              'Service Manual',
      link:               '/service-manual',
      manual:             '/service-manual',
      organisations:      ['government-digital-service'],
    )
  end
end

RSpec.describe ServiceStandardSearchIndexer, '#delete' do
  it 'deletes the homepage from rummager' do
    stub_any_rummager_delete_content

    described_class.new.delete

    assert_rummager_deleted_content '/service-manual'
  end
end
