require 'rails_helper'

RSpec.describe "Preventing users from losing unsaved changes in the form", type: :feature do
  before do
    allow_any_instance_of(GuidePublisher).to receive(:put_draft)
    allow_any_instance_of(SearchIndexer).to receive(:index)
  end

  it "asks the user for confirmation when navigating away via 'Request review'", js: true do
    edition = Generators.valid_edition(title: "Standups", state: 'draft')
    guide = Guide.create!(latest_edition: edition, slug: "/service-manual/test")
    visit edit_guide_path(guide)
    fill_in "Body", with: "This has changed"
    click_first_button "Send for review"
    expect(page.driver.browser.modal_message).to include "unsaved changes"
  end
end
