require 'rails_helper'

RSpec.describe 'Guide index', type: :feature do
  it "removes the Community part from guide community titles" do
    guide = create(:guide)

    visit root_path

    content_owner_title =
      guide.latest_edition.content_owner.title
    content_owner_title_without_community =
      guide.latest_edition.content_owner.title.gsub(" Community", "")

    within_guide_index_row guide.title do
      expect(page).to_not have_content content_owner_title
      expect(page).to have_content content_owner_title_without_community
    end
  end
end
