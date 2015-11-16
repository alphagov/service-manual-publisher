require 'rails_helper'
require 'capybara/rails'

RSpec.describe "Slug migration", type: :feature do
  def expect_table_to_match_migrations migrations
    within ".slug-migrations .table" do
      table_data = page.all("tr").map do |row|
        row.all("td").map(&:text)
      end

      expected = migrations.map do |m|
        [
          m.completed? ? "Show" : "Manage",
          m.slug,
          String(m.try(:guide).try(:slug)),
        ]
      end.reverse
      expect(table_data).to eq(expected)
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

  def show_first_migration
    manage_migrations
    within ".slug-migrations .table" do
      click_link "Show"
    end
  end

  context "with incomplete migrations" do
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

  context "can filter migrations" do
    before do
      @incompleted = (1..2).map do |i|
        SlugMigration.create!(completed: false, slug: "/old/bar#{i}")
      end

      edition = Generators.valid_published_edition
      guide = Guide.create!(slug: "/service-manual/something", latest_edition: edition)
      @complete = (1..2).map do |i|
        SlugMigration.create!(completed: true, slug: "/old/foo#{i}", guide: guide)
      end

      manage_migrations
    end

    it "based on complete" do
      within ".slug-filters" do
        click_link "Completed 2"
      end
      expect_table_to_match_migrations @complete
    end

    it "based on incompleted" do
      within ".slug-filters" do
        click_link "Not completed 2"
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

    expect(page).to have_content "Slug Migration has been saved"
    selected_text = find(:css, ".slug-migration-select-guide option[selected]").text
    expect(selected_text).to eq "/service-manual/new-path"
  end

  it "can only migrate guides with published editions" do
    Guide.create!(slug: "/service-manual/path1", latest_edition: Generators.valid_edition(state: "draft"))
    Guide.create!(slug: "/service-manual/path2", latest_edition: Generators.valid_edition(state: "review_requested"))
    Guide.create!(slug: "/service-manual/path3", latest_edition: Generators.valid_edition(state: "published"))

    SlugMigration.create!(completed: false, slug: "/service-manual/some-jekyll-path.html")

    manage_first_migration

    options = all(:css, ".slug-migration-select-guide option").map(&:text)
    expect(options).to eq [
      "Please choose a guide to redirect to",
      "/service-manual/path3",
    ]
  end

  it "can not migrate an old slug to a new slug without a guide" do
    SlugMigration.create!(completed: false, slug: "/service-manual/some-jekyll-path.html")
    manage_first_migration
    click_button "Save and Migrate"
    expect(page).to have_content "must not be blank"
  end

  it "migrates an old url to a new url" do
    edition = Generators.valid_published_edition
    Guide.create!(slug: "/service-manual/new-path", latest_edition: edition)
    slug_migration = SlugMigration.create!(completed: false, slug: "/service-manual/some-jekyll-path.html")

    expect_any_instance_of(SlugMigrationPublisher).to receive(:process).with(slug_migration)

    manage_first_migration
    select "/service-manual/new-path", from: "Guide"

    click_button "Save and Migrate"

    expect(page).to have_content "Slug Migration has been completed"
    expect(slug_migration.reload.completed).to eq true
    expect(page.current_path).to eq slug_migration_path(slug_migration)
  end

  context "completed slug migrations" do
    it "only shows the migration, and does not allow editing" do
      edition = Generators.valid_published_edition
      guide = Guide.create!(slug: "/service-manual/something", latest_edition: edition)
      slug_migration = SlugMigration.create!(completed: true, slug: "/old/foo", guide: guide)
      show_first_migration
      expect(page.current_path).to eq slug_migration_path(slug_migration)
    end
  end

  context "with a failing publisher-api" do
    it "is not marked as completed" do
      edition = Generators.valid_published_edition
      Guide.create!(slug: "/service-manual/new-path", latest_edition: edition)
      slug_migration = SlugMigration.create!(completed: false, slug: "/service-manual/some-jekyll-path.html")

      api_error = GdsApi::HTTPClientError.new(422, "Error message stub", "error" => { "message" => "Error message stub" })
      expect_any_instance_of(SlugMigrationPublisher).to receive(:process).and_raise api_error

      manage_first_migration
      select "/service-manual/new-path", from: "Guide"

      click_button "Save and Migrate"

      expect(page).to have_content "Error message stub"
      expect(slug_migration.reload.completed).to eq false
      expect(page.current_path).to eq slug_migration_path(slug_migration)
    end
  end
end
