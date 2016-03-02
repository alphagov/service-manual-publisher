require 'rails_helper'
require 'capybara/rails'

RSpec.describe "Commenting", type: :feature do
  describe 'for a normal guide' do
    it 'write a comment successfully' do
      edition = Generators.valid_edition(title: 'Lean Startup')
      guide = Guide.create!(
                latest_edition: edition,
                slug: "/service-manual/test/comment"
              )

      write_a_comment_successfully(guide: guide)
    end
  end

  describe 'for a guide community' do
    it 'write a comment successfully' do
      edition = Generators.valid_edition(title: 'Agile Community', content_owner: nil)
      guide = Generators.valid_guide_community(latest_edition: edition)
      guide.save!

      write_a_comment_successfully(guide: guide)
    end
  end

  def write_a_comment_successfully(guide:)
    visit root_path
    within_guide_index_row(guide.latest_edition.title) do
      click_link "Edit"
    end
    click_link "Comments and history"

    within ".comments" do
      fill_in "Add new comment", with: "This is my comment"
      click_button "Save comment"
    end

    expect(page.current_path).to eq edition_comments_path(guide.latest_edition)

    within ".comments .comment" do
      expect(page).to have_content "Stub User"
      expect(page).to have_content "This is my comment"
    end
  end
end
