require 'rails_helper'

RSpec.describe GuidePublisher do
  context "when a guide is of state 'draft'" do
    let(:guide) do
      Guide.create(latest_edition: Generators.valid_edition(state: 'draft'), slug: "/test/slug")
    end

    describe "#put_draft" do
      it "sends draft payload to publishing API" do
        publisher = GuidePublisher.new(guide: guide)

        double_api = double(:publishing_api)
        expected_plek = Plek.new.find('publishing-api')
        expected_json = {test: :json}
        expected_token = { bearer_token: 'example' }
        double_guide_presenter = double(:guide_presenter)
        expect(double_guide_presenter).to receive(:exportable_attributes)
                                            .and_return(expected_json)
        expect(GuidePresenter).to receive(:new)
                                    .with(guide, guide.latest_edition)
                                    .and_return(double_guide_presenter)
        expect(GdsApi::PublishingApiV2).to receive(:new)
                                           .with(expected_plek, expected_token)
                                           .and_return(double_api)
        expect(double_api).to receive(:put_content)
                                .with(guide.content_id, expected_json)
        publisher.put_draft
      end
    end
  end

  describe "#publish" do
    it "publishes the latest edition via publishing API" do
      edition = Generators.valid_edition(state: 'published', update_type: 'major')
      guide = Guide.create!(slug: "/service-manual/test/slug", latest_edition: edition)

      publisher = GuidePublisher.new(guide: guide)

      double_api = double(:publishing_api)
      expected_plek = Plek.new.find('publishing-api')
      expected_token = { bearer_token: 'example' }
      payload_double = { test: :json }

      expect(GdsApi::PublishingApiV2).to receive(:new)
                                        .with(expected_plek, expected_token)
                                        .and_return(double_api)

      expect(double_api).to receive(:publish)
                              .once
                              .with(guide.content_id, 'major')
      publisher.publish
    end
  end
end
