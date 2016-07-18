require 'rails_helper'

RSpec.describe GuideHelper, '#guide_community_options_for_select', type: :helper do
  it 'returns an array of options for a select tag in alphabetical order' do
    second = create(:guide_community, editions: [build(:edition, title: 'Banana', content_owner: nil)])
    first = create(:guide_community, editions: [build(:edition, title: 'Apple', content_owner: nil)])
    third = create(:guide_community, editions: [build(:edition, title: 'Cucumber', content_owner: nil)])

    expect(helper.guide_community_options_for_select).to eq(
      [
        [first.title,  first.id],
        [second.title, second.id],
        [third.title, third.id],
      ]
    )
  end
end

RSpec.describe GuideHelper, '#guide_types_for_select', type: :helper do
  it 'returns an array of options for a select tag' do
    guide_community_edition = build(:edition, content_owner: nil, title: "Agile Community")
    guide_community = create(:guide_community, editions: [guide_community_edition])

    edition = build(:edition, content_owner: guide_community, title: "Scrum")
    create(:guide, editions: [edition])

    # explicitly create a guide with an 'empty' type, to check we don't get
    # a blank option in the drop down.
    create(:guide, type: '')

    expect(helper.guide_types_for_select).to match_array(
      [
        %w(All All),
        %w(Guide Guide),
        ['Guide Community', 'GuideCommunity'],
      ]
    )
  end
end

RSpec.describe GuideHelper, '#topic_section_options_for_select', type: :helper do
  it "returns topic sections options for a grouped select tag" do
    topic = create(:topic, path: "/service-manual/agile", title: "Agile")
    topic_section = create(:topic_section, topic: topic, title: "Scrum")

    expect(helper.topic_section_options_for_select).to eq(
      [
        [
          "Agile",
          [["Agile -> Scrum", topic_section.id]],
          { "data-path" => "/agile" }
        ]
      ]
    )
  end
end
