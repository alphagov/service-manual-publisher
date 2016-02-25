require 'rails_helper'
require 'capybara/rails'
require 'gds_api/rummager'

RSpec.describe "Slug migration", type: :feature do
  before do
    @rummager_double = double(:rummager)
    allow(GdsApi::Rummager).to receive(:new).and_return @rummager_double
    allow(@rummager_double).to receive(:get_content!).and_return(true)
  end

  def expect_table_to_match_migrations migrations
    within ".slug-migrations .table" do
      table_data = page.all("tr").map do |row|
        row.all("td").map(&:text)
      end

      expected = migrations.map do |m|
        [
          m.completed? ? "Show" : "Manage",
          m.slug,
          m.redirect_to || "",
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

  def create_slug_migration_without_redirect_to slug
    slug_migration = SlugMigration.new(slug: slug, completed: false)
    slug_migration.save!(validate: false)
    slug_migration
  end

  context "with incomplete migrations" do
    before do
      @migrations = (1..3).map do |i|
        create_slug_migration_without_redirect_to "/old/bar/#{i}"
      end
    end

    it "lists all migrations that are available" do
      manage_migrations

      expect_table_to_match_migrations @migrations
    end
  end

  context "migration filter" do
    before do
      @incompleted = (1..2).map do |i|
        create_slug_migration_without_redirect_to "/old/bar/#{i}"
      end

      edition = Generators.valid_published_edition
      guide = Guide.create!(slug: "/service-manual/something", latest_edition: edition)
      @complete = (1..2).map do |i|
        SlugMigration.create!(
          completed: true,
          slug: "/old/foo#{i}",
          redirect_to: guide.slug,
        )
      end

      manage_migrations
    end

    it "filters on complete" do
      within ".slug-filters" do
        click_link "Completed 2"
      end
      expect_table_to_match_migrations @complete
    end

    it "filters on incompleted" do
      within ".slug-filters" do
        click_link "Not completed 2"
      end
      expect_table_to_match_migrations @incompleted
    end
  end

  it "migrates to the root" do
    slug_migration = create_slug_migration_without_redirect_to(
      "/service-manual/some-jekyll-path.html",
    )
    expect_any_instance_of(SlugMigrationPublisher).to receive(:process).with(slug_migration)

    manage_first_migration

    select "/service-manual", from: "Redirect to"
    click_button "Migrate"

    expect(page).to have_content "Slug Migration has been completed"
    expect(slug_migration.reload.completed).to eq true
    expect(page.current_path).to eq slug_migration_path(slug_migration)
  end

  it "migrates to a guide slug" do
    edition = Generators.valid_published_edition
    Guide.create!(slug: "/service-manual/new-path", latest_edition: edition)

    slug_migration = create_slug_migration_without_redirect_to(
      "/service-manual/some-jekyll-path.html",
    )
    expect_any_instance_of(SlugMigrationPublisher).to receive(:process).with(slug_migration)

    manage_first_migration

    select "/service-manual/new-path", from: "Redirect to"
    click_button "Migrate"

    expect(page).to have_content "Slug Migration has been completed"
    expect(slug_migration.reload.completed).to eq true
    expect(page.current_path).to eq slug_migration_path(slug_migration)
  end

  it "can't migrate to unpublished guides" do
    edition = Generators.valid_edition
    Guide.create!(slug: "/service-manual/new-path", latest_edition: edition)

    create_slug_migration_without_redirect_to(
      "/service-manual/some-jekyll-path.html",
    )
    manage_first_migration

    expect(page).to_not have_content "/service-manual/new-path"
  end

  it "migrates to a topic path" do
    Generators.valid_topic!(path: "/service-manual/topic-1")

    slug_migration = create_slug_migration_without_redirect_to(
      "/service-manual/some-jekyll-path.html",
    )
    expect_any_instance_of(SlugMigrationPublisher).to receive(:process).with(slug_migration)

    manage_first_migration

    select "/service-manual/topic-1", from: "Redirect to"
    click_button "Migrate"

    expect(page).to have_content "Slug Migration has been completed"
    expect(slug_migration.reload.completed).to eq true
    expect(page.current_path).to eq slug_migration_path(slug_migration)
  end

  context "completed slug migrations" do
    it "only shows the migration, and does not allow editing" do
      slug_migration = SlugMigration.create!(
        completed: true,
        slug: "/old/foo",
        redirect_to: "/some-path",
      )
      show_first_migration
      expect(page.current_path).to eq slug_migration_path(slug_migration)
    end
  end

  context "with a failing publisher-api" do
    it "is not marked as completed" do
      edition = Generators.valid_published_edition
      Guide.create!(slug: "/service-manual/new-path", latest_edition: edition)
      slug_migration = create_slug_migration_without_redirect_to(
        "/service-manual/some-jekyll-path.html",
      )

      api_error = GdsApi::HTTPClientError.new(422, "Error message stub", "error" => { "message" => "Error message stub" })
      expect_any_instance_of(SlugMigrationPublisher).to receive(:process).and_raise api_error

      manage_first_migration
      select "/service-manual/new-path", from: "Redirect to"

      click_button "Migrate"

      expect(page).to have_content "Error message stub"
      expect(slug_migration.reload.completed).to eq false
      expect(page.current_path).to eq slug_migration_path(slug_migration)
    end
  end

  context "with a slug migration" do
    before do
      edition = Generators.valid_published_edition
      guide = Guide.create!(slug: "/service-manual/path", latest_edition: edition)
      @slug_migration = SlugMigration.create!(
        completed: false,
        slug: "/service-manual/path.html",
        redirect_to: guide.slug,
      )
    end

    context "that has a search index" do
      it "allows the search index to be deleted" do
        expect(@rummager_double).to receive(:get_content!).with(@slug_migration.slug).twice.and_return(true)
        expect(@rummager_double).to receive(:delete_content!).with(@slug_migration.slug)

        visit root_path
        click_link "Manage Migrations"
        click_link "Manage"
        click_button "Delete from search index"
        expect(page).to have_content "Document has been removed from search"
      end
    end

    context "that does not have a search index" do
      it "does not allow the search index to be deleted" do
        not_found_error = GdsApi::HTTPNotFound.new(404, "error", "error")
        expect(@rummager_double).to receive(:get_content!).with(@slug_migration.slug).and_raise(not_found_error)

        visit root_path
        click_link "Manage Migrations"
        click_link "Manage"
        expect(page).to_not have_button "Delete from search index"
      end
    end
  end
end
