require 'rails_helper'
require 'capybara/rails'

RSpec.describe "Commenting", type: :feature do
  let(:guide) do
    create(
      :guide,
      slug: "/service-manual/test/comment",
      latest_edition: build(:edition, title: "Lean Startup"),
    )
  end

  describe 'for a normal guide' do
    it 'write a comment successfully' do
      comment = "This is a guide comment"
      write_a_comment(guide: guide, comment: comment)

      within ".comment" do
        expect(page).to have_content "Stub User"
        expect(page).to have_content comment
      end
    end

    it "auto links urls in comments" do
      guide = create(:guide, :with_draft_edition)
      comment = "This is a link: http://google.com"
      write_a_comment(guide: guide, comment: comment)

      within ".comment" do
        expect(page).to have_link "http://google.com", href: "http://google.com"
      end
    end
  end

  describe 'for a guide community' do
    it 'write a comment successfully' do
      guide = create(:guide_community)
      comment = "This is a guide community comment"
      write_a_comment(guide: guide, comment: comment)

      within ".comment" do
        expect(page).to have_content "Stub User"
        expect(page).to have_content comment
      end
    end
  end

  def write_a_comment(guide:, comment:)
    visit root_path
    within_guide_index_row(guide.latest_edition.title) do
      click_link guide.title
    end
    click_link "Comments and history"

    within ".open-edition" do
      fill_in "Add new comment", with: comment
      click_button "Save comment"
    end
    expect(page.current_path).to eq edition_comments_path(guide.latest_edition)
  end
end
