require 'rails_helper'

RSpec.describe GuidePublisher do
  it "saves published items" do
    guide = Guide.new(slug: "/test/slug", latest_edition: Generators.valid_edition(state: 'published'))
    publisher = GuidePublisher.new(guide)

    double_api = double(:publishing_api)
    expected_plek = Plek.new.find('publishing-api')
    expected_json = {test: :json}
    double_guide_presenter = double(:guide_presenter)
    expect(double_guide_presenter).to receive(:exportable_attributes)
                                        .and_return(expected_json)
    expect(GuidePresenter).to receive(:new)
                                .with(guide, guide.latest_edition)
                                .and_return(double_guide_presenter)
    expect(GdsApi::PublishingApi).to receive(:new)
                                      .with(expected_plek)
                                      .and_return(double_api)
    expect(double_api).to receive(:put_content_item)
                            .with(guide.slug, expected_json)
    publisher.publish!
  end

  it "saves draft items" do
    guide = Guide.new(latest_edition: Generators.valid_edition, slug: "/test/slug")
    publisher = GuidePublisher.new(guide)

    double_api = double(:publishing_api)
    expected_plek = Plek.new.find('publishing-api')
    expected_json = {test: :json}
    double_guide_presenter = double(:guide_presenter)
    expect(double_guide_presenter).to receive(:exportable_attributes)
                                        .and_return(expected_json)
    expect(GuidePresenter).to receive(:new)
                                .with(guide, guide.latest_edition)
                                .and_return(double_guide_presenter)
    expect(GdsApi::PublishingApi).to receive(:new)
                                       .with(expected_plek)
                                       .and_return(double_api)
    expect(double_api).to receive(:put_draft_content_item)
                            .with(guide.slug, expected_json)
    publisher.publish!
  end
end
