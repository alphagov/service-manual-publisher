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
end
