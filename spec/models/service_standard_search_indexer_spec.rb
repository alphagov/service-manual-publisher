require 'rails_helper'

RSpec.describe ServiceStandardSearchIndexer, '#index' do
  it 'indexes a document in rummager' do
    stub_any_rummager_post

    described_class.new.index

    assert_rummager_posted_item(
      _type:              'service_manual_guide',
      _id:                '/service-manual/service-standard',
      format:             'service_manual_guide',
      description:        'The Digital Service Standard is a set of 18 criteria to help government create and run good digital services.',
      indexable_content:  'All public facing transactional services must meet the standard. It’s used by departments and the Government Digital Service to check whether a service is good enough for public use.',
      title:              'Digital Service Standard',
      link:               '/service-manual/service-standard',
      manual:             '/service-manual',
      organisations:      ['government-digital-service'],
    )
  end
end

RSpec.describe ServiceStandardSearchIndexer, '#delete' do
  it 'deletes documents from rummager' do
    stub_any_rummager_delete_content

    described_class.new.delete

    assert_rummager_deleted_content '/service-manual/service-standard'
  end
end
