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
