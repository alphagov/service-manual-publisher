require 'rails_helper'
require 'capybara/rails'
require 'gds_api/publishing_api_v2'

RSpec.describe "Topics", type: :feature do
  let(:api_double) { double(:publishing_api) }

  it "before creating a new topic it cannot be published" do
    visit root_path
    click_link "Manage Topics"
    click_link "Create a Topic"

    expect(page).to_not have_button('Publish')
  end

  it "save a draft topic", js: true do
    stub_const("PUBLISHING_API", api_double)
    expect(api_double).to receive(:put_content)
                            .once
                            .with(an_instance_of(String), be_valid_against_schema('service_manual_topic'))
    expect(api_double).to receive(:patch_links)
                            .once
                            .with(an_instance_of(String), an_instance_of(Hash))
    guide1 = create(:guide, editions: [ build(:edition, title: 'Guide 1') ])
    guide2 = create(:guide, editions: [ build(:edition, title: 'Guide 2') ])

    visit root_path
    click_link "Manage Topics"
    click_link "Create a Topic"

    fill_in "Path", with: "/service-manual/something"
    fill_in "Title", with: "The title"
    fill_in "Description", with: "The description"
    click_button "Add Heading"
    fill_in "Heading Title", with: "The heading title"
    fill_in "Heading Description", with: "The heading description"
    add_guide guide1.id
    add_guide guide2.id
    click_button "Save"

    visit edit_topic_path(Topic.first)

    expect(page).to have_field('Title', with: 'The title')
    expect(page).to have_field('Description', with: 'The description')

    expect(find('.js-topic-title').value).to eq('The heading title')
    expect(find('.js-topic-description').value).to eq('The heading description')

    guide_ids = all('.js-grouped-list .js-guide').map {|e| e["data-guide-id"]}
    expect(guide_ids).to eq [
      guide1.id.to_param,
      guide2.id.to_param,
    ]
  end

  it "links to a preview from a saved draft" do
    create(:topic, title: 'Agile Delivery', path: '/service-manual/agile-delivery-topic')

    visit root_path
    click_link "Manage Topics"
    click_link "Agile Delivery"

    expect(page).to have_link('Preview', href: %r{/service-manual/agile-delivery-topic})
  end

  it "update a topic to save another draft" do
    stub_const("PUBLISHING_API", api_double)
    expect(api_double).to receive(:put_content)
                            .once
                            .with(an_instance_of(String), be_valid_against_schema('service_manual_topic'))
    expect(api_double).to receive(:patch_links)
                            .once
                            .with(an_instance_of(String), an_instance_of(Hash))
    topic = create(:topic, title: 'Agile Delivery')

    visit root_path
    click_link "Manage Topics"
    click_link "Agile Delivery"

    fill_in 'Description', with: 'Updated description'

    click_button 'Save'

    within('.alert') do
      expect(page).to have_content('Topic has been updated')
    end

    # Reload the page to be sure the fields don't contain params from the
    # previous request
    visit current_path

    expect(page).to have_field('Description', with: 'Updated description')
  end

  it "publish a topic" do
    stub_const("PUBLISHING_API", api_double)
    expect(api_double).to receive(:publish).
                          once
    topic = create(:topic, :with_some_guides)

    # When publishing a topic we also need to update the links for all the relevant
    # guides so that they can display which topic they're in.
    #
    # Expect that the batch operation to patch the links is called
    expect(GuideTaggerJob).to receive(:batch_perform_later)
      .with(topic)

    # Expect that the topic is attempted to be indexed for search
    topic_search_indexer = double(:topic_search_indexer)
    expect(topic_search_indexer).to receive(:index)
    expect(TopicSearchIndexer).to receive(:new) { topic_search_indexer }

    visit root_path
    click_link "Manage Topics"
    click_link topic.title

    click_on 'Publish'

    within('.alert') do
      expect(page).to have_content('Topic has been published')
    end
  end

  def add_guide(id)
    page.execute_script("$('.js-guide[data-guide-id=#{id}]').appendTo('.js-guides')")
  end
end

RSpec.describe "topic editor", type: :feature do
  it "can view topics" do
    Topic.create!(
      path: "/service-manual/topic1",
      title: "Topic 1",
      description: "A Description",
    )
    visit root_path
    click_link "Manage Topics"
    click_link "Topic 1"
    expect(page).to have_link "View", href: "http://www.dev.gov.uk/service-manual/topic1"
  end
end
