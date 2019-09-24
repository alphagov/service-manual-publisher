require "rails_helper"

RSpec.describe GuideRouteHelper, "#guide_frontend_published_url" do
  it "returns the URL a guide should be published at" do
    guide = Guide.new(slug: "/service-manual/technology")

    expect(
      helper.guide_frontend_published_url(guide),
    ).to eq("#{Plek.find('www')}/service-manual/technology")
  end
end
