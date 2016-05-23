require 'rails_helper'

RSpec.describe GuideHelper, '#guide_community_options_for_select', type: :helper do
  it 'returns an array of options for a select tag in alphabetical order' do
    second = create(:guide_community, editions: [ build(:edition, title: 'Banana', content_owner: nil) ])
    first = create(:guide_community, editions: [ build(:edition, title: 'Apple', content_owner: nil) ])
    third = create(:guide_community, editions: [ build(:edition, title: 'Cucumber', content_owner: nil) ])

    expect(helper.guide_community_options_for_select).to eq(
      [
        [first.title,  first.id],
        [second.title, second.id],
        [third.title,   third.id],
      ]
    )
  end
end

RSpec.describe GuideHelper, '#guide_types_for_select', type: :helper do
  it 'returns an array of options for a select tag' do
    guide_community_edition = build(:edition, content_owner: nil, title: "Agile Community")
    guide_community = create(:guide_community, editions: [ guide_community_edition ])

    edition = build(:edition, content_owner: guide_community, title: "Scrum")
    guide = create(:guide, editions: [ edition ])

    expect(helper.guide_types_for_select).to match_array(
      [
        ['All', 'All'],
        ['Guide', 'Guide'],
        ['Guide Community', 'GuideCommunity'],
      ]
    )
  end
end
