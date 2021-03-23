shared_examples "common service manual draft payload" do
  # If the payload includes public_updated_at then the user facing timestamp on the
  # frontend will reflect the time the draft was saved rather than the time it was
  # published. For the service manual we want to display the published time to the user.
  #
  # https://github.com/alphagov/content-store/blob/master/docs/content_item_fields.md#public_updated_at
  #
  it "omits public_updated_at" do
    expect(payload).to_not have_key(:public_updated_at)
  end

  it "is published by the service-manual-publisher" do
    expect(payload).to include(publishing_app: "service-manual-publisher")
  end

  it "is rendering by the service-manual-frontend" do
    expect(payload).to include(rendering_app: "service-manual-frontend")
  end

  it "is in locale en" do
    expect(payload).to include(locale: "en")
  end
end
