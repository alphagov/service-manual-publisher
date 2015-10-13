require 'rails_helper'
require 'capybara/rails'

RSpec.describe "guide", type: :feature do
  it "stores guide metadata" do
    visit root_path
    click_link "Create a Guide"

    fill_in "Slug", with: "/the/path"
    click_button "Publish"

    guide = Guide.first
    expect(guide.slug).to eq "/the/path"
  end

  it "saves draft guides" do

  end
end
