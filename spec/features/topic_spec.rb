require 'rails_helper'
require 'capybara/rails'
require 'gds_api/publishing_api_v2'

RSpec.describe "create topics", type: :feature do
  before { allow_any_instance_of(TopicPublisher).to receive(:publish_immediately) }

  it "can create a new topic", js: true do
    edition1 = Generators.valid_edition(title: "Title 1")
    edition2 = Generators.valid_edition(title: "Title 2")
    Guide.create!(slug: "/service-manual/edition1", latest_edition: edition1)
    Guide.create!(slug: "/service-manual/edition2", latest_edition: edition2)

    visit root_path
    click_link "Manage Topics"
    click_link "Create a new topic"
    fill_in "Path", with: "/service-manual/something"
    fill_in "Title", with: "The title"
    fill_in "Description", with: "The description"

    click_button "Add Heading"
    fill_in "Heading Title", with: "The heading title"
    fill_in "Heading Description", with: "The heading description"

    click_button "Add Edition"
    all(".js-topic-edition")[0].find("option[value='#{edition1.id}']").select_option

    click_button "Add Edition"
    all(".js-topic-edition")[1].find("option[value='#{edition2.id}']").select_option

    click_button "Save"

    expect(Topic.count).to eq 1
    topic = Topic.first
    expect(topic.title).to eq "The title"
    expect(topic.description).to eq "The description"
    expect(topic.tree.to_json).to eq(
      [
        {
          "title":"The heading title",
          "editions": ["12", "13"],
          "description": "The heading description",
        }
      ].to_json
    )
  end
end
