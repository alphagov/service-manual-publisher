require 'rails_helper'

RSpec.describe Publisher, '#save_draft' do

  it 'persists the content model' do
    guide = Generators.valid_guide
    publishing_api = FakePublishingApi.new

    Publisher.new(content_model: guide, publishing_api: publishing_api).
              save_draft

    expect(guide).to be_persisted
  end

  class FakePublishingApi
    def put_content(content_id, data)
    end
  end

  it 'sends the draft to the publishing api' do
    guide = Generators.valid_guide
    guide.save!
    publishing_api = double(:publishing_api)

    expect(publishing_api).to receive(:put_content).
                              with(guide.content_id, {})

    Publisher.new(content_model: guide, publishing_api: publishing_api).
              save_draft
  end

  it 'does not send the draft to the publishing api if the content model is not valid' do
    guide = Generators.valid_guide(slug: '/invalid-slug')
    expect(guide).to_not be_valid

    publishing_api = double(:publishing_api)

    expect(publishing_api).to_not receive(:put_content)

    Publisher.new(content_model: guide, publishing_api: publishing_api).
              save_draft
  end

  it 'does not persist the content model if the publishing api call fails' do
    guide = Generators.valid_guide
    publishing_api = double(:publishing_api)
    gds_api_exception = GdsApi::HTTPErrorResponse.new(422,
                                          'https://some-service.gov.uk',
                                          {'error' => {'message' => 'trouble'}})
    allow(publishing_api).to receive(:put_content).and_raise(gds_api_exception)

    Publisher.new(content_model: guide, publishing_api: publishing_api).
              save_draft

    expect(guide).to be_new_record
  end
end
