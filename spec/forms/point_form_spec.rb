require "rails_helper"

RSpec.describe PointForm, "validations" do
  it "does not require topic_section_id" do
    guide = Point.new
    edition = guide.editions.build
    guide_form = described_class.new(guide: guide, edition: edition, user: User.new)
    guide_form.save

    expect(guide_form.errors.full_messages).to_not include("Topic section can't be blank")
  end
end
