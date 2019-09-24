require "rails_helper"

RSpec.describe "Generating topic slugs", type: :feature, js: true do
  context "when creating a new topic" do
    it "generates slugs automatically based on the title" do
      visit new_topic_path

      fill_in "Title", with: "My First Topic"

      expect(page).to have_field "Slug", with: "my-first-topic"
      expect(page).to have_field "Final URL", with: "/service-manual/my-first-topic"
    end
  end

  context "when editing an existing topic" do
    it "does not modify the slug when editing a topic" do
      topic = create(:topic, path: "/service-manual/my-first-topic")

      visit edit_topic_path(topic)

      fill_in "Title", with: "Totally renamed this topic"

      expect(page).to have_field "Slug", with: "my-first-topic", disabled: true
      expect(page).to have_field "Final URL", with: "/service-manual/my-first-topic", disabled: true
    end
  end
end
