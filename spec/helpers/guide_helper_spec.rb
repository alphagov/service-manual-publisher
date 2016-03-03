require 'rails_helper'

RSpec.describe GuideHelper, '#guide_community_options_for_select', type: :helper do
  it 'returns an array of options for a select tag in alphabetical order' do
    first = create(:guide_community)
    second = create(:guide_community)
    third = create(:guide_community)

    expect(helper.guide_community_options_for_select).to eq(
      [
        [first.title,  first.id],
        [second.title, second.id],
        [third.title,   third.id],
      ]
    )
  end
end
