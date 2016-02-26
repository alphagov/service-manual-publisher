require 'rails_helper'

RSpec.describe GuideHelper, '#guide_community_options_for_select', type: :helper do
  it 'returns an array of options for a select tag in alphabetical order' do
    design = Generators.valid_guide_community(
      latest_edition: Generators.valid_edition(content_owner: nil, title: 'Design Community')).tap(&:save!)
    agile  = Generators.valid_guide_community(
      latest_edition: Generators.valid_edition(content_owner: nil, title: 'Agile Community')).tap(&:save!)
    tech   = Generators.valid_guide_community(
      latest_edition: Generators.valid_edition(content_owner: nil, title: 'Tech Community')).tap(&:save!)

    expect(helper.guide_community_options_for_select).to eq(
      [
        ['Agile Community',  agile.id],
        ['Design Community', design.id],
        ['Tech Community',   tech.id]
      ]
      )
  end
end
