require "rails_helper"

RSpec.describe "republish" do
  let!(:publish_request) { stub_any_publishing_api_publish }

  before do
    stub_any_publishing_api_put_content
    stub_any_publishing_api_patch_links
  end

  describe "guides" do
    before do
      Rake::Task["republish:guides"].reenable
    end

    it "republishes live guides" do
      create :guide, :with_published_edition
      expect { Rake::Task["republish:guides"].invoke }.to output.to_stdout
      expect(publish_request).to have_been_requested
    end

    it "ignores other guides" do
      create :guide
      Rake::Task["republish:guides"].invoke
      expect(publish_request).to_not have_been_requested
    end
  end

  describe "topics" do
    before do
      Rake::Task["republish:topics"].reenable
    end

    it "republishes topics" do
      create :topic
      expect { Rake::Task["republish:topics"].invoke }.to output.to_stdout
      expect(publish_request).to have_been_requested
    end
  end

  describe "homepage" do
    before do
      Rake::Task["republish:homepage"].reenable
    end

    it "republishes the home page" do
      Rake::Task['republish:homepage'].invoke
      expect(publish_request).to have_been_requested
    end
  end
end
