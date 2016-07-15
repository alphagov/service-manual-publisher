require 'rails_helper'

RSpec.describe "unpublishing guides", type: :feature do
  before do
    GDS::SSO.test_user = create(:user, name: "Bob")
  end

  let(:guide) { create(:guide, :with_published_edition, title: "Outdated guide") }
  let!(:topic) { create(:topic, path: "/service-manual/suitable-redirect") }

  context 'when the publishing api is available' do
    before do
      stub_any_publishing_api_call
      stub_any_rummager_delete_content
    end

    it 'requires you to choose a redirect destination' do
      visit unpublish_guide_path(guide)
      click_button "Unpublish"

      expect(page.current_path).to eq unpublish_guide_path(guide)
      expect(page).to have_content "Redirect destination can't be blank"
    end

    it 'creates a record of the redirect' do
      visit unpublish_guide_path(guide)
      select topic.path, from: "Redirect to"
      click_button "Unpublish"

      # We are storing where the user redirected to in the `redirects`
      # table but we aren't displaying in the browser yet. Therefore
      # we are testing it here.
      expect(
        Redirect.find_by(old_path: guide.slug, new_path: topic.path)
      ).to be_present
    end

    it 'unpublishes the content, creating a redirect' do
      visit unpublish_guide_path(guide)
      select topic.path, from: "Redirect to"
      click_button "Unpublish"

      assert_publishing_api_unpublish(guide.content_id,
        type: 'redirect',
        alternative_path: '/service-manual/suitable-redirect'
      )
    end

    it 'removes the guide from the search index' do
      visit unpublish_guide_path(guide)
      select topic.path, from: "Redirect to"
      click_button "Unpublish"

      assert_rummager_deleted_content guide.slug
    end

    it 'redirects to the edit page and displays a success message' do
      visit unpublish_guide_path(guide)
      select topic.path, from: "Redirect to"
      click_button "Unpublish"

      expect(page.current_path).to eq edit_guide_path(guide)
      expect(page).to have_content "Guide has been unpublished"
    end

    it 'records the guide as unpublished' do
      visit unpublish_guide_path(guide)
      select topic.path, from: "Redirect to"
      click_button "Unpublish"

      expect(page.current_path).to eq edit_guide_path(guide)
      expect(page).to have_content "Unpublished"
    end

    it 'records who unpublished the guide in the history' do
      visit unpublish_guide_path(guide)
      select topic.path, from: "Redirect to"
      click_button "Unpublish"

      visit(guide_editions_path(guide))
      within_guide_history_edition(1) do
        expect(page).to have_content("Unpublished by Bob")
      end
    end

    context 'unpublishing guides created before we stored who created an edition' do
      it "does not error and sets the guide state to Unpublished" do
        # Fake the situation we have in production where the
        # `editions.created_by_id` field is NULL
        latest_edition = guide.latest_edition
        latest_edition.created_by_id = nil
        latest_edition.save(validate: false)

        visit unpublish_guide_path(guide)
        select topic.path, from: "Redirect to"
        click_button "Unpublish"

        expect(current_path).to eq edit_guide_path(guide)
        expect(page).to have_content("Unpublished")
      end
    end
  end

  context 'when the publishing api is not available' do
    before do
      publishing_api_isnt_available
    end

    it 'does not redirect you to the edit screen' do
      visit unpublish_guide_path(guide)
      select topic.path, from: "Redirect to"
      click_button "Unpublish"

      expect(page.current_path).to eq unpublish_guide_path(guide)
    end

    it 'displays an error message' do
      visit unpublish_guide_path(guide)
      select topic.path, from: "Redirect to"
      click_button "Unpublish"

      expect(page).to have_content 'Could not communicate with upstream API'
    end

    it 'does not record a redirect' do
      visit unpublish_guide_path(guide)
      select topic.path, from: "Redirect to"
      click_button "Unpublish"

      # We are storing where the user redirected to in the `redirects`
      # table but we aren't displaying in the browser yet. Therefore
      # we are testing it here.
      expect(Redirect.find_by(old_path: guide.slug)).not_to be_present
    end

    it 'does not record the guide as unpublished' do
      visit unpublish_guide_path(guide)
      select topic.path, from: "Redirect to"
      click_button "Unpublish"

      visit edit_guide_path(guide)

      expect(page).not_to have_content "Unpublished"
    end
  end
end

RSpec.describe 'Once a guide has been unpublished', type: :feature do
  it 'can no longer be edited' do
    guide = create(:guide, :has_been_unpublished)

    visit edit_guide_path(guide)

    expect(page).to_not have_field("Title")
    expect(page).to_not have_field("Description")
    expect(page).to_not have_field("Body")
    expect(page).to_not have_field("Community")

    expect(page).to_not have_field("Minor update")
    expect(page).to_not have_field("Major update")
    expect(page).to_not have_field("Summary of change")
    expect(page).to_not have_field("Why the change is being made")

    expect(page).to_not have_field("Author")
  end

  it 'can no longer be saved' do
    guide = create(:guide, :has_been_unpublished)
    visit edit_guide_path(guide)

    expect(page).to_not have_button "Save"
  end

  it 'can no longer be sent for review' do
    guide = create(:guide, :has_been_unpublished)
    visit edit_guide_path(guide)

    expect(page).to_not have_button "Send for review"
  end

  it 'can no longer be discarded as a new guide' do
    guide = create(:guide, :has_been_unpublished)
    visit edit_guide_path(guide)

    expect(page).to_not have_button "Discard new guide"
  end

  it 'can no longer be discarded as a draft' do
    guide = create(:guide, :has_been_unpublished)
    visit edit_guide_path(guide)

    expect(page).to_not have_button "Discard draft"
  end

  it 'can no longer be unpublished' do
    guide = create(:guide, :has_been_unpublished)
    visit edit_guide_path(guide)

    expect(page).to_not have_link "Unpublish"
  end
end
