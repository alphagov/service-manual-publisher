require 'rails_helper'
require 'capybara/rails'

RSpec.describe "Slug migration", type: :feature do
  feature "with incomplete migrations" do
    before do
      @migrations = (1..3).map do |i|
        SlugMigration.create(completed: false, slug: "/old/bar#{i}")
      end
    end

    it "lists all migrations that are available" do
      visit root_path

      within "nav" do
        click_link "Manage Migrations"
      end

      within ".migrations .table" do
        table_data = page.all("tr").map do |row|
          row.all("td").map(&:text)
        end

        expect(table_data).to eq(@migrations.map { |m| ["", m.slug, m.completed.to_s] })
      end
    end
  end

  feature "can filter migrations" do
    it "based on complete"
    it "based on incompleted"
  end

  it "can complete a migration event for incompleted migrations"
end
