require 'rails_helper'
require 'capybara/rails'
require 'gds_api/publishing_api_v2'

RSpec.describe "creating guides", type: :feature do
  let(:api_double) { double(:publishing_api) }

  before do
    create(:guide_community)
  end

  let :slug_examples do
    {
      "two words": "two-words",
      "slug--with-----hyphens": "slug-with-hyphens",
      "       space    slugs  ": "space-slugs",
      'other things !@#$%^&*()_-+=/\\': "other-things",
    }
  end


  describe "slug generation" do
    context "guide that has not been published" do
      let :guide do
        create(:guide, :with_draft_edition, :with_topic_section)
      end

      it "generates slug and final url", js: true do
        visit edit_guide_path(guide)

        slug_examples.each do |title, expected_slug|
          fill_in "Title", with: title
          expect(find_field('Slug').value).to eq expected_slug
          expect(find_field('Final URL').value).to eq "#{guide.topic.path}/#{expected_slug}"
        end
      end

      context "user edits slug manually" do
        it "does not generate slug", js: true do
          visit edit_guide_path(guide)

          fill_in "Slug", with: "something"
          fill_in "Title", with: "My Guide Title"
          select "Agile Delivery -> Topic Section Title", from: "Topic section", exact: true
          expect(find_field('Slug').value).to eq "something"
          expect(find_field('Final URL').value).to eq "#{guide.topic.path}/something"
        end
      end
    end


    context "published guide" do
      it "does not generate slug and final url", js: true do
        guide = create(:published_guide, :with_topic_section)
        visit edit_guide_path(guide)

        fill_in "Title", with: "My Guide Title"
        expect(find_field('Slug', disabled: true).value).to eq guide.slug.split("/").last
        expect(find_field('Final URL', disabled: true).value).to eq guide.slug
      end
    end

  end
end
