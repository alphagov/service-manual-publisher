require 'rails_helper'

RSpec.describe ServiceStandardSearchIndexer, '#index' do
  it 'indexes a document in rummager' do
    expect(RUMMAGER_API).to receive(:add_document).with(
      'service_manual_guide',
      '/service-manual/service-standard',
      format:            'service_manual_guide',
      description:       'The Digital Service Standard is a set of 18 criteria to help government create and run good digital services.',
      indexable_content: 'All public facing transactional services must meet the standard. It’s used by departments and the Government Digital Service to check whether a service is good enough for public use.',
      title:             'Digital Service Standard',
      link:              '/service-manual/service-standard',
      manual:            '/service-manual',
      organisations:     ['government-digital-service'],
    )

    described_class.new.index
  end
end

RSpec.describe ServiceStandardSearchIndexer, '#delete' do
  it 'deletes documents from rummager' do
    expect(RUMMAGER_API).to receive(:delete_content!)
      .with('/service-manual/service-standard')

    described_class.new.delete
  end
end
