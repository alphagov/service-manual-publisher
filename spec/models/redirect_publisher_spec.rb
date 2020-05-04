require "rails_helper"

RSpec.describe RedirectPublisher, type: :model do
  it "publishes redirects" do
    content_id = SecureRandom.uuid
    old_path   = "/service-manual/some-jekyll-path.html"
    new_path   = "/service-manual/something"

    expected_redirect = {
      schema_name: "redirect",
      update_type: "major",
      document_type: "redirect",
      publishing_app: "service-manual-publisher",
      base_path: old_path,
      redirects: [
        {
          path: old_path,
          type: "exact",
          destination: new_path,
        },
      ],
    }

    api = double(:publishing_api)
    expect(api).to receive(:put_content)
      .with(content_id, expected_redirect)
    expect(api).to receive(:publish)
      .once.with(content_id)

    RedirectPublisher.new(api).process(
      content_id: content_id,
      old_path: old_path,
      new_path: new_path,
    )
  end

  it "publishes redirects that are valid" do
    content_id = SecureRandom.uuid
    old_path   = "/service-manual/some-jekyll-path.html"
    new_path   = "/service-manual/something"

    api = double(:publishing_api)
    expect(api).to receive(:put_content)
      .with(an_instance_of(String), be_valid_against_schema("redirect"))
    expect(api).to receive(:publish)
      .once.with(content_id)

    RedirectPublisher.new(api).process(
      content_id: content_id,
      old_path: old_path,
      new_path: new_path,
    )
  end
end
