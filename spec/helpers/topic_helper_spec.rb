require 'rails_helper'

RSpec.describe TopicHelper, "#topic_view_url" do
  it "returns correct content url" do
    topic = Topic.new(path: "/service-manual/a-topic")
    expect(view_topic_url(topic)).to eq "http://www.dev.gov.uk/service-manual/a-topic"
  end
end


RSpec.describe TopicHelper, "#all_guides_container_for_select" do
  it "returns the container of pairs for all guides suitable for options_for_select" do
    agile_community = create(:guide_community,
                             editions: [build(:edition,
                                             content_owner: nil,
                                             title: 'Agile Community')
                                        ])
    agile = create(:guide,
                   editions: [
                     build(:edition, title: 'Agile', content_owner: agile_community, created_at: 1.week.ago),
                     build(:edition, title: 'Agile old', content_owner: agile_community, created_at: 1.month.ago),
                     ])

    expected = [
      ['Agile', agile.id],
      ['Agile Community', agile_community.id]
    ]
    expect(helper.all_guides_container_for_select).to eq(expected)
  end
end
