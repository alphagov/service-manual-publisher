require "rails_helper"

RSpec.describe "Generating slugs", type: :feature, js: true do
  context "when the guide has not been published" do
    it "updates the slug and final url when changing the title or section" do
      examples = {
        'two words': "two-words",
        'slug--with-----hyphens': "slug-with-hyphens",
        '       space    slugs  ': "space-slugs",
        'other things !@#$%^&*()_-+=/\\': "other-things",
      }
      topic_section = create(:topic_section)
      topic_section_label = "#{topic_section.topic.title} -> #{topic_section.title}"
      visit new_guide_path

      examples.each do |title, expected_slug|
        fill_in "Title", with: title
        select topic_section_label, from: "Topic section", exact: true

        expect(page).to have_field "Slug", with: expected_slug
        expect(page).to have_field "Final URL", with: "#{topic_section.topic.path}/#{expected_slug}"
      end
    end

    context "when the user has manually edited the slug" do
      it "does not update the slug or final url when you change the title" do
        topic = create(:topic, path: "/service-manual/my-topic")
        topic_section = create(:topic_section, topic:)
        topic_section_label = "#{topic.title} -> #{topic_section.title}"

        visit new_guide_path

        fill_in "Slug", with: "something"
        fill_in "Title", with: "My Guide Title"

        select topic_section_label, from: "Topic section", exact: true

        expect(page).to have_field "Slug", with: "something"
        expect(page).to have_field "Final URL", with: "/service-manual/my-topic/something"
      end

      it "remembers that the slug was edited when coming back to edit it" do
        topic = create(:topic, path: "/service-manual/my-topic")
        topic_section = create(:topic_section, topic:)

        guide = create(:guide, :with_draft_edition, slug: "/service-manual/my-topic/my-custom-slug", topic:)
        topic_section.guides << guide

        visit edit_guide_path(guide)

        fill_in "Title", with: "A New Title"
        expect(page).to have_field "Slug", with: "my-custom-slug"
        expect(page).to have_field "Final URL", with: "/service-manual/my-topic/my-custom-slug"
      end
    end
  end

  context "when the guide has been published" do
    it "does not update the slug or final url when you change the title" do
      guide = create(:guide, :with_published_edition)
      visit edit_guide_path(guide)

      fill_in "Title", with: "My Guide Title"

      title_slug = guide.slug.split("/").last

      expect(page).to have_field "Slug", with: title_slug, disabled: true
      expect(page).to have_field "Final URL", with: guide.slug, disabled: true
    end
  end
end
