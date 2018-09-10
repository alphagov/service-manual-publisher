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

    # Get the beforeunload function return value (prompt).
    page_unload_prompt = page.evaluate_script("window.onbeforeunload.call()")
    expect(page_unload_prompt).to include("unsaved changes")

    accept_confirm do
      click_first_button "Send for review"
    end
    # It's necessary in this test to return to the edit page
    # otherwise the spec will complete regardless of the js
    # confirmation. This means the database will be truncated and
    # the subsequent #find! in the controller will raise an error
    # as all records have already been deleted.
    visit edit_guide_path(guide)
  end

  it "does not notify the user when navigating away via 'Save'", js: true do
    guide = create(:guide, :with_draft_edition, slug: "/service-manual/topic-name/test")
    visit edit_guide_path(guide)
    fill_in "Body", with: "This has changed"
    click_first_button "Save"
    expect {
      page.driver.browser.switch_to.alert
    }.to raise_error(Selenium::WebDriver::Error::NoAlertPresentError)
  end
end
