require 'rails_helper'
require 'capybara/rails'

RSpec.describe "Commenting", type: :feature do
  let(:guide) do
    create(
      :guide,
      slug: "/service-manual/test/comment",
      editions: [build(:edition, title: "Lean Startup")],
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

    it "presents multi line comments correctly" do
      guide = create(:guide, :with_draft_edition)

      comment_text = %{This guide sure could use more cow bell.
Cow bell makes everything better!

Much better.}
      formatted_comment = %{<p>This guide sure could use more cow bell.
<br>Cow bell makes everything better!</p>

<p>Much better.</p>}

      write_a_comment(guide: guide, comment: comment_text)

      comment_html = find('.comment').native.inner_html
      expect(comment_html).to include formatted_comment
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
    expect(page.current_path).to eq guide_editions_path(guide)
  end
end
