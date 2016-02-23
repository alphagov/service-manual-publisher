require 'rails_helper'
require 'capybara/rails'
require 'gds_api/publishing_api_v2'

RSpec.describe "topic editor", type: :feature do
  before do
    allow_any_instance_of(TopicPublisher).to receive(:publish_immediately)
    ContentOwner.create!(title: "Design Community", href: "example.com/design")
    ContentOwner.create!(title: "Agile Community", href: "example.com/agile")
  end

  it "can create a new topic", js: true do
    edition1 = Generators.valid_edition(title: "Title 1")
    edition2 = Generators.valid_edition(title: "Title 2")
    guide1 = Guide.create!(slug: "/service-manual/edition1", latest_edition: edition1)
    guide2 = Guide.create!(slug: "/service-manual/edition2", latest_edition: edition2)

    visit root_path
    click_link "Manage Topics"
    click_link "Create a Topic"
    fill_in "Path", with: "/service-manual/something"
    fill_in "Title", with: "The title"
    fill_in "Description", with: "The description"

    select "Agile Community", from: "Content Owner"
    select "Design Community", from: "Content Owner"

    click_button "Add Heading"
    fill_in "Heading Title", with: "The heading title"
    fill_in "Heading Description", with: "The heading description"

    click_button "Add Guide"
    all(".js-topic-guide")[0].find("option[value='#{guide1.id}']").select_option

    click_button "Add Guide"
    all(".js-topic-guide")[1].find("option[value='#{guide2.id}']").select_option

    click_button "Save"

    expect(Topic.count).to eq 1
    topic = Topic.first
    expect(topic.title).to eq "The title"
    expect(topic.description).to eq "The description"
    expect(topic.content_owners.map(&:title)).to match_array(["Design Community", "Agile Community"])
    expect(topic.tree.to_json).to eq(
      [
        {
          "title": "The heading title",
          "guides": [guide1.id.to_s, guide2.id.to_s],
          "description": "The heading description",
        }
      ].to_json
    )
  end

  it "can view topics" do
    topic = Topic.create!(
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
