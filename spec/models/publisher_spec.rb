require 'rails_helper'

RSpec.describe Publisher, '#save_draft' do

  it 'persists the content model and returns a successful response' do
    guide = build(:guide, :with_draft_edition)
    publishing_api = double(:publishing_api)
    allow(publishing_api).to receive(:put_content)
    allow(publishing_api).to receive(:patch_links)

    publication_response =
      Publisher.new(content_model: guide, publishing_api: publishing_api)
               .save_draft(GuidePresenter.new(guide, guide.latest_edition))

    expect(guide).to be_persisted
    expect(publication_response).to be_success
  end

  it 'sends the draft and the links to the publishing api' do
    guide = create(:guide, :with_draft_edition)
    publishing_api = double(:publishing_api)

    expect(publishing_api).to receive(:put_content).
                              with(guide.content_id, a_hash_including(base_path: guide.slug))
    expect(publishing_api).to receive(:patch_links).
                              with(guide.content_id, a_kind_of(Hash))

    Publisher.new(content_model: guide, publishing_api: publishing_api).
              save_draft(GuidePresenter.new(guide, guide.latest_edition))
  end

  it 'does not send the draft to the publishing api if the content model is not valid'\
    ' and returns an unsuccessful response' do
    guide = build(:guide, slug: '/invalid-slug')
    expect(guide).to_not be_valid

    publishing_api = double(:publishing_api)

    expect(publishing_api).to_not receive(:put_content)

    publication_response =
      Publisher.new(content_model: guide, publishing_api: publishing_api)
               .save_draft(GuidePresenter.new(guide, guide.latest_edition))

    expect(publication_response).to_not be_success
  end

  context 'when the publishing api call fails' do
    let(:guide) { build(:guide, :with_draft_edition) }
    let(:publishing_api_which_always_fails) do
      api = double(:publishing_api)
      gds_api_exception = GdsApi::HTTPErrorResponse.new(422,
                                            'https://some-service.gov.uk',
                                            {'error' => {'message' => 'trouble'}})
      allow(api).to receive(:put_content).and_raise(gds_api_exception)
      api
    end

    it 'does not persist the content model and returns an unsuccessful response' do
      publication_response =
        Publisher.new(content_model: guide, publishing_api: publishing_api_which_always_fails).
                  save_draft(GuidePresenter.new(guide, guide.latest_edition))

      expect(Guide.find_by_id(guide.id)).to eq(nil)
      expect(publication_response).to_not be_success
    end

    it 'returns the gds api error messages' do
      publication_response =
        Publisher.new(content_model: guide, publishing_api: publishing_api_which_always_fails).
                  save_draft(GuidePresenter.new(guide, guide.latest_edition))

      expect(publication_response.errors).to include('trouble')
    end
  end
end

RSpec.describe Publisher, '#publish' do
  it 'sends the draft to the publishing api' do
    guide = create(:guide, :with_draft_edition)
    publishing_api = double(:publishing_api)

    expect(publishing_api).to receive(:publish).
                              with(guide.content_id, guide.latest_edition.update_type)

    Publisher.new(content_model: guide, publishing_api: publishing_api).
              publish
  end
end
