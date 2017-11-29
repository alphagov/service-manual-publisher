require 'rails_helper'

RSpec.describe "Preventing users from losing unsaved changes in the form", type: :feature do
  before do
    publishing_api = double(:publishing_api)
    allow(publishing_api).to receive(:put_content)
    stub_const('PUBLISHING_API', publishing_api)
  end

  it "asks the user for confirmation when navigating away via 'Request review'", js: true do
    guide = create(:guide, :with_draft_edition, slug: "/service-manual/topic-name/test")
    visit edit_guide_path(guide)
    fill_in "Body", with: "This has changed"
    click_first_button "Send for review"
    expect(page.driver.browser.modal_message).to include "unsaved changes"
  end

  it "does not notify the user when navigating away via 'Save'", js: true do
    guide = create(:guide, :with_draft_edition, slug: "/service-manual/topic-name/test")
    visit edit_guide_path(guide)
    fill_in "Body", with: "This has changed"
    click_first_button "Save"
    expect(page.driver.browser.modal_message).to be_blank
  end
end
