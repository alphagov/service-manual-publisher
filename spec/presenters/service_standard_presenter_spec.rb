require "rails_helper"

RSpec.describe ServiceStandardPresenter, "#content_id" do
  it "is a preassigned UUID" do
    point_scope = double(:point_scope)

    expect(
      described_class.new(point_scope).content_id
    ).to eq("00f693d4-866a-4fe6-a8d6-09cd7db8980b")
  end
end

RSpec.describe ServiceStandardPresenter, "#links_payload" do
  it "includes points" do
    point1 = create(:point)
    point2 = create(:point)

    expected_payload = {
      links: {
        points: [point1.content_id, point2.content_id]
      }
    }

    expect(
      described_class.new([point1, point2]).links_payload
    ).to eq(expected_payload)
  end
end
