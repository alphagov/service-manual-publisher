require 'rails_helper'

RSpec.describe 'Generating slugs', type: :feature, js: true do
  context 'when the guide has not been published' do
    it 'updates the slug and final url when changing the title or section' do
      examples = {
        'two words': 'two-words',
        'slug--with-----hyphens': 'slug-with-hyphens',
        '       space    slugs  ': 'space-slugs',
        'other things !@#$%^&*()_-+=/\\': 'other-things',
      }
      topic_section = create(:topic_section)
      topic_section_label = "#{topic_section.topic.title} -> #{topic_section.title}"
      visit new_guide_path

      examples.each do |title, expected_slug|
        fill_in 'Title', with: title
        select topic_section_label, from: 'Topic section', exact: true

        expect(find_field('Slug').value).to eq expected_slug
        expect(find_field('Final URL').value).to eq "#{topic_section.topic.path}/#{expected_slug}"
      end
    end

    context 'when the user has manually edited the slug' do
      it 'does not update the slug or final url when you change the title' do
        guide = create(:guide, :with_draft_edition, :with_topic_section)
        visit edit_guide_path(guide)

        fill_in 'Slug', with: 'something'
        fill_in 'Title', with: 'My Guide Title'
        select 'Agile Delivery -> Topic Section Title', from: 'Topic section', exact: true

        expect(find_field('Slug').value).to eq 'something'
        expect(find_field('Final URL').value).to eq "#{guide.topic.path}/something"
      end
    end
  end

  context 'when the guide has been published' do
    it 'does not update the slug or final url when you change the title' do
      guide = create(:guide, :with_published_edition, :with_topic_section)
      visit edit_guide_path(guide)

      fill_in 'Title', with: 'My Guide Title'

      expect(find_field('Slug', disabled: true).value).to eq guide.slug.split('/').last
      expect(find_field('Final URL', disabled: true).value).to eq guide.slug
    end
  end
end
