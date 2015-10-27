require 'rails_helper'

RSpec.describe GuidePublisher do
  context "when a guide is of state 'draft'" do
    let(:guide) do
      Guide.create(latest_edition: Generators.valid_edition(state: 'draft'), slug: "/test/slug")
    end

    it "saves draft items" do
      publisher = GuidePublisher.new(guide: guide, edition: guide.latest_edition)

      double_api = double(:publishing_api)
      expected_plek = Plek.new.find('publishing-api')
      expected_json = {test: :json}
      double_guide_presenter = double(:guide_presenter)
      expect(double_guide_presenter).to receive(:exportable_attributes)
                                          .and_return(expected_json)
      expect(GuidePresenter).to receive(:new)
                                  .with(guide, guide.latest_edition)
                                  .and_return(double_guide_presenter)
      expect(GdsApi::PublishingApiV2).to receive(:new)
                                         .with(expected_plek)
                                         .and_return(double_api)
      expect(double_api).to receive(:put_content)
                              .with(guide.content_id, expected_json)
      publisher.process
    end
  end

  context "when a guide is of state 'published'" do
    let(:guide) do
      edition = Generators.valid_edition(state: 'published', update_type: 'major')
      Guide.create(slug: "/test/slug", latest_edition: edition)
    end

    it "saves draft then publishes it" do
      publisher = GuidePublisher.new(guide: guide, edition: guide.latest_edition)

      double_api = double(:publishing_api)
      expected_plek = Plek.new.find('publishing-api')
      payload_double = { test: :json }
      double_guide_presenter = double(:guide_presenter)
      expect(double_guide_presenter).to receive(:exportable_attributes)
                                          .and_return(payload_double)
      expect(GuidePresenter).to receive(:new)
                                  .with(guide, guide.latest_edition)
                                  .and_return(double_guide_presenter)
      expect(GdsApi::PublishingApiV2).to receive(:new)
                                        .with(expected_plek)
                                        .and_return(double_api)
      expect(double_api).to receive(:put_content)
                              .with(guide.content_id, payload_double)

      expect(double_api).to receive(:publish)
                              .with(guide.content_id, 'major')
      publisher.process
    end
  end
end
