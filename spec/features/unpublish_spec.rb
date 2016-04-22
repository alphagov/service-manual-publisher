require 'rails_helper'
require 'capybara/rails'

RSpec.describe "unpublishing guides", type: :feature do
  context "with a published guide" do
    before do
      allow_any_instance_of(RedirectPublisher).to receive(:process)
      allow_any_instance_of(SearchIndexer).to receive(:delete)
    end

    it "redirects to topics" do
      guide = create(:published_guide)
      topic = create(:topic, path: "/service-manual/agile-delivery")

      expect_any_instance_of(RedirectPublisher).to receive(:process).with(
        content_id: anything,
        old_path:   guide.slug,
        new_path:   topic.path,
      )

      visit edit_guide_path(guide)
      click_first_link "Unpublish"
      select topic.path, from: "Redirect to"
      click_button "Unpublish"

      expect(Unpublish.count).to eq 1
      expect(Unpublish.first.old_path).to eq guide.slug
      expect(Unpublish.first.new_path).to eq topic.path
      expect(guide.reload.latest_edition).to be_unpublished
    end

    it "redirects to guides" do
      guide = create(:published_guide)
      new_guide = create(:published_guide)

      expect_any_instance_of(RedirectPublisher).to receive(:process).with(
        content_id: anything,
        old_path:   guide.slug,
        new_path:   new_guide.slug,
      )

      visit edit_guide_path(guide)
      click_first_link "Unpublish"
      select new_guide.slug, from: "Redirect to"
      click_button "Unpublish"

      expect(Unpublish.count).to eq 1
      expect(Unpublish.first.old_path).to eq guide.slug
      expect(Unpublish.first.new_path).to eq new_guide.slug
      expect(guide.reload.latest_edition).to be_unpublished
    end

    it "disables all form submits in the guide editor" do
      guide = create(:unpublished_guide)

      visit edit_guide_path(guide)

      expect(page).to_not have_button "Save"
      expect(page).to_not have_button "Send for review"
      expect(page).to_not have_button "Discard new guide"
      expect(page).to_not have_button "Discard draft"
      expect(page).to_not have_link "Unpublish"
    end

    it "stores the user who unpublished the guide" do
      guide = create(:published_guide)
      new_guide = create(:published_guide)

      previous_author = create(:user)
      guide.editions.update_all(author_id: previous_author.id)

      allow_any_instance_of(RedirectPublisher).to receive(:process)

      visit edit_guide_path(guide)
      click_first_link "Unpublish"
      select new_guide.slug, from: "Redirect to"
      click_button "Unpublish"

      expect(guide.latest_edition.author).to_not eq previous_author
    end

    it "removes the guide from the search index" do
      guide = create(:published_guide)
      new_guide = create(:published_guide)

      allow_any_instance_of(RedirectPublisher).to receive(:process)

      indexer = double(:indexer)
      expect(SearchIndexer).to receive(:new).with(guide).and_return(indexer)
      expect(indexer).to receive(:delete)

      visit edit_guide_path(guide)
      click_first_link "Unpublish"
      select new_guide.slug, from: "Redirect to"
      click_button "Unpublish"
    end

    it "disables all inputs in the guide editor" do
      guide = create(:unpublished_guide)

      visit edit_guide_path(guide)

      expect(page).to_not have_field("Title")
      expect(page).to_not have_field("Description")
      expect(page).to_not have_field("Body")
      expect(page).to_not have_field("Community")

      expect(page).to_not have_field("Minor update")
      expect(page).to_not have_field("Major update")
      expect(page).to_not have_field("Summary of change")
      expect(page).to_not have_field("Why the change is being made")

      expect(page).to_not have_field("Author")
    end
  end
end
