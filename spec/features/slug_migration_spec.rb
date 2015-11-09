require 'rails_helper'
require 'capybara/rails'

RSpec.describe "Slug migration", type: :feature do
  def expect_table_to_match_migrations migrations
    within ".migrations .table" do
      table_data = page.all("tr").map do |row|
        row.all("td").map(&:text)
      end

      expect(table_data).to eq(migrations.map { |m| ["", m.slug, m.completed.to_s] })
    end
  end

  feature "with incomplete migrations" do
    before do
      @migrations = (1..3).map do |i|
        SlugMigration.create!(completed: false, slug: "/old/bar#{i}")
      end
    end

    it "lists all migrations that are available" do
      visit root_path

      within "nav" do
        click_link "Manage Migrations"
      end

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

      visit root_path
      within "nav" do
        click_link "Manage Migrations"
      end
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

  it "can complete a migration event for incompleted migrations"
end
