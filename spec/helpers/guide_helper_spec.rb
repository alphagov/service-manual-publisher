require 'rails_helper'

RSpec.describe GuideHelper, '#guide_community_options_for_select', type: :helper do
  it 'returns an array of options for a select tag in alphabetical order' do
    second = create(:guide_community, :with_published_edition, title: 'Banana')
    first = create(:guide_community, :with_published_edition, title: 'Apple')
    third = create(:guide_community, :with_published_edition, title: 'Cucumber')

    expect(helper.guide_community_options_for_select).to eq(
      [
        [first.title,  first.id],
        [second.title, second.id],
        [third.title, third.id],
      ]
    )
  end

  it "excludes unpublished guide communities" do
    create(:guide_community, :has_been_unpublished, title: 'Not to be returned')
    guide = create(:guide_community, :with_published_edition, title: 'Banana')

    expect(helper.guide_community_options_for_select).to eq(
      [
        [guide.title, guide.id]
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
