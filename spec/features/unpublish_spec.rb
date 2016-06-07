require 'rails_helper'
require 'capybara/rails'

RSpec.describe "unpublishing guides", type: :feature do
  context "with a published guide" do
    before do
      allow_any_instance_of(RedirectPublisher).to receive(:process)
      allow_any_instance_of(GuideSearchIndexer).to receive(:delete)
    end

    it "creates a Redirect record and marks as unpublished" do
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

      expect(Redirect.count).to eq 1
      expect(Redirect.first.old_path).to eq guide.slug
      expect(Redirect.first.new_path).to eq topic.path
      expect(guide.reload.latest_edition).to be_unpublished
    end

    context "before we stored who created an edition" do
      it "creates a Redirect record and marks as unpublished" do
        guide = create(:published_guide)
        latest_edition = guide.latest_edition
        latest_edition.created_by_id = nil
        latest_edition.save(validate: false)
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

        expect(Redirect.count).to eq 1
        expect(Redirect.first.old_path).to eq guide.slug
        expect(Redirect.first.new_path).to eq topic.path
        expect(guide.reload.latest_edition).to be_unpublished
      end
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

    it "removes the guide from the search index" do
      guide = create(:published_guide)
      new_guide = create(:published_guide)

      allow_any_instance_of(RedirectPublisher).to receive(:process)

      indexer = double(:indexer)
      expect(GuideSearchIndexer).to receive(:new).with(guide).and_return(indexer)
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

    it "disables the summary field for a points page" do
      guide = create(:unpublished_point)

      visit edit_guide_path(guide)

      expect(page).to_not have_field("Summary")
    end
  end
end
