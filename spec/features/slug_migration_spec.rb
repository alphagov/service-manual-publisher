require 'rails_helper'

RSpec.describe "Slug migration", type: :feature do
  def expect_table_to_match_migrations migrations
    within ".slug-migrations .table" do
      table_data = page.all("tbody tr").map do |row|
        row.all("td").map(&:text)
      end

      expected = migrations.map do |m|
        [
          m.completed? ? "Show" : "Manage",
          m.slug,
          m.redirect_to || "",
        ]
      end
      expect(table_data).to eq(expected.reverse)
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

      guide = create(:guide, :with_published_edition)
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
    expect_any_instance_of(RedirectPublisher).to receive(:process).with(
      content_id: anything,
      old_path:   slug_migration.slug,
      new_path:   "/service-manual",
    )

    manage_first_migration

    select "/service-manual", from: "Redirect to"
    click_button "Migrate"

    expect(page).to have_content "Slug Migration has been completed"
    expect(slug_migration.reload.completed).to eq true
    expect(page.current_path).to eq slug_migration_path(slug_migration)
  end

  it "migrates to a guide slug" do
    guide = create(:guide, :with_published_edition)

    slug_migration = create_slug_migration_without_redirect_to(
      "/service-manual/some-jekyll-path.html",
    )

    expect_any_instance_of(RedirectPublisher).to receive(:process).with(
      content_id: anything,
      old_path:   slug_migration.slug,
      new_path:   guide.slug,
    )

    manage_first_migration

    select guide.slug, from: "Redirect to"
    click_button "Migrate"

    expect(page).to have_content "Slug Migration has been completed"
    expect(slug_migration.reload.completed).to eq true
    expect(page.current_path).to eq slug_migration_path(slug_migration)
  end

  it "can't migrate to unpublished guides" do
    guide = create(:guide, :with_draft_edition, slug: "/service-manual/topic-name/new-path")

    create_slug_migration_without_redirect_to(
      "/service-manual/some-jekyll-path.html",
    )
    manage_first_migration

    expect(page).to_not have_content guide.slug
  end

  it "migrates to a topic path" do
    create(:topic, path: "/service-manual/topic-1")

    slug_migration = create_slug_migration_without_redirect_to(
      "/service-manual/some-jekyll-path.html",
    )
    expect_any_instance_of(RedirectPublisher).to receive(:process).with(
      content_id: anything,
      old_path:   slug_migration.slug,
      new_path:   "/service-manual/topic-1",
    )

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
    context "that raises GdsApi::HTTPServerError" do
      it "does not migrate" do
        create(:guide, :with_published_edition, slug: "/service-manual/topic-name/new-path")

        slug_migration = create_slug_migration_without_redirect_to(
          "/service-manual/some-jekyll-path.html",
        )

        api_error = GdsApi::HTTPServerError.new(500, "Error Message!")
        expect_any_instance_of(RedirectPublisher).to receive(:process).and_raise api_error

        manage_first_migration
        select "/service-manual/topic-name/new-path", from: "Redirect to"

        click_button "Migrate"

        expect(page).to have_content "An error was encountered while trying to publish the slug redirect"
        expect(slug_migration.reload).to_not be_completed
        expect(page.current_path).to eq slug_migration_path(slug_migration)
      end
    end

    context "that raises GdsApi::HTTPNotFound" do
      it "does not migrate" do
        guide = create(:guide, :with_published_edition)

        slug_migration = create_slug_migration_without_redirect_to(
          "/service-manual/some-jekyll-path.html",
        )

        api_error = GdsApi::HTTPNotFound.new(404, "Error Message!")
        expect_any_instance_of(RedirectPublisher).to receive(:process).and_raise api_error

        manage_first_migration
        select guide.slug, from: "Redirect to"

        click_button "Migrate"

        expect(page).to have_content "Couldn't migrate slug because the previous slug does not exist"
        expect(slug_migration.reload).to_not be_completed
        expect(page.current_path).to eq slug_migration_path(slug_migration)
      end
    end
  end
end
