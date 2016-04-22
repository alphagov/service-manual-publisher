require 'rails_helper'

RSpec.describe RedirectPublisher, type: :model do
  it "publishes redirects" do
    content_id = SecureRandom.uuid
    old_path   = "/service-manual/some-jekyll-path.html"
    new_path   = "/service-manual/something"

    expected_redirect = {
      format: "redirect",
      publishing_app: "service-manual-publisher",
      base_path: old_path,
      redirects: [
        {
          path: old_path,
          type: "exact",
          destination: new_path,
        }
      ]
    }

    api_double = double(:publishing_api)
    expect(GdsApi::PublishingApiV2).to receive(:new).and_return(api_double)
    expect(api_double).to receive(:put_content)
      .with(content_id, expected_redirect)
    expect(api_double).to receive(:publish)
      .once.with(content_id, 'major')

    RedirectPublisher.new.process(
      content_id: content_id,
      old_path:   old_path,
      new_path:   new_path,
    )
  end

  it "publishes redirects that are valid" do
    content_id = SecureRandom.uuid
    old_path   = "/service-manual/some-jekyll-path.html"
    new_path   = "/service-manual/something"

    api_double = double(:publishing_api)
    expect(GdsApi::PublishingApiV2).to receive(:new).and_return(api_double)
    expect(api_double).to receive(:put_content)
      .with(an_instance_of(String), be_valid_against_schema('redirect'))
    expect(api_double).to receive(:publish)
      .once.with(content_id, 'major')

    RedirectPublisher.new.process(
      content_id: content_id,
      old_path:   old_path,
      new_path:   new_path,
    )
  end
end
