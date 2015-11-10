require 'rails_helper'
require 'capybara/rails'

RSpec.describe "Slug migration", type: :feature do
  def expect_table_to_match_migrations migrations
    within ".slug-migrations .table" do
      table_data = page.all("tr").map do |row|
        row.all("td").map(&:text)
      end

      expect(table_data).to eq(migrations.map { |m| ["Manage", m.slug, m.completed.to_s] })
    end
  end

  def manage_migrations
    visit root_path
    within "nav" do
      click_link "Manage Migrations"
    end
  end

  def manage_first_migration
    manage_migrations
    within ".slug-migrations .table" do
      click_link "Manage"
    end
  end

  feature "with incomplete migrations" do
    before do
      @migrations = (1..3).map do |i|
        SlugMigration.create!(completed: false, slug: "/old/bar#{i}")
      end
    end

    it "lists all migrations that are available" do
      manage_migrations

      expect_table_to_match_migrations @migrations
    end
  end

  feature "can filter migrations" do
    before do
      @incompleted = (1..2).map do |i|
        SlugMigration.create!(completed: false, slug: "/old/bar#{i}")
      end
      @complete = (1..2).map do |i|
        SlugMigration.create!(completed: true, slug: "/old/foo#{i}")
      end

      manage_migrations
    end

    it "based on complete" do
      within ".slug-filters" do
        click_link "Filter by completed"
      end
      expect_table_to_match_migrations @complete
    end

    it "based on incompleted" do
      within ".slug-filters" do
        click_link "Filter by incompleted"
      end
      expect_table_to_match_migrations @incompleted
    end
  end

  it "can save a slug migration" do
    edition = Generators.valid_published_edition
    Guide.create!(slug: "/service-manual/new-path", latest_edition: edition)

    SlugMigration.create!(completed: false, slug: "/service-manual/some-jekyll-path.html")

    manage_first_migration

    select "/service-manual/new-path", from: "Guide"
    click_button "Save"

    expect(page).to have_content "Slug Migration has been updated"
    selected_text = find(:css, "#slug_migration_guide option[selected]").text
    expect(selected_text).to eq "/service-manual/new-path"
  end

  it "can migrate an old url to a new url"
end
