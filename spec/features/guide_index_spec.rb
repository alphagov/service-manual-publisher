require "rails_helper"

RSpec.describe "Guide index", type: :feature do
  it "removes the Community part from guide community titles" do
    guide = create(:guide, :with_draft_edition)

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

  it "displays the version number from the latest edition" do
    guide = create(:guide, :with_published_edition)
    guide.editions << create(:edition, :draft, version: 2)

    visit root_path

    within_guide_index_row guide.title do
      expect(page).to have_content "Edition 2"
    end
  end

  it "displays the update type of the latest edition" do
    major_update_guide = create(:guide, :with_published_edition)
    major_update_guide.editions << create(:edition, :draft,
                                          update_type: "major",
                                          title: "First Update Guide")

    minor_update_guide = create(:guide, :with_published_edition)
    minor_update_guide.editions << create(:edition, :draft,
                                          update_type: "minor",
                                          title: "Second Update Guide",
                                          version: 2)

    visit root_path

    within_guide_index_row major_update_guide.title do
      expect(page).to have_content "Major update"
    end

    within_guide_index_row minor_update_guide.title do
      expect(page).to have_content "Minor update"
    end
  end

  it "displays the status of a guide" do
    create(:guide, :with_ready_edition, slug: "/service-manual/topic-name/something", title: "Something")

    visit root_path
    within_guide_index_row("Something") do
      within ".label" do
        expect(page).to have_content "Ready"
      end
    end
  end
end
