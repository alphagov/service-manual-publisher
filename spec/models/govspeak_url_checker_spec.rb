require 'rails_helper'

RSpec.describe GovspeakUrlChecker do
  describe "#find_broken_links" do
    let :success do
      OpenStruct.new(code: 200)
    end

    let :fail do
      OpenStruct.new(code: 500)
    end

    it "lists broken links" do
      expect(HTTParty).to receive(:get)
        .with("http://example.org/one", follow_redirects: true, timeout: 5)
        .and_return success
      expect(HTTParty).to receive(:get)
        .with("http://example.org/two", follow_redirects: true, timeout: 5)
        .and_return fail

      govspeak = <<-GOVSPEAK
[link 1](http://example.org/one)
[link 2](http://example.org/two)
      GOVSPEAK
      broken_links = GovspeakUrlChecker.new(govspeak).find_broken_links
      expect(broken_links).to eq ["http://example.org/two"]
    end

    it "caches already checked urls" do
      expect(HTTParty).to receive(:get)
        .with("http://some-url.com/url", follow_redirects: true, timeout: 5)
        .once
        .and_return success

      govspeak = "[link](http://some-url.com/url)"
      GovspeakUrlChecker.new(govspeak).find_broken_links
      GovspeakUrlChecker.new(govspeak).find_broken_links
    end

    it "ignores mailto: links" do
      expect(HTTParty).to receive(:get)
        .with("http://example.org", follow_redirects: true, timeout: 5)
        .and_return success

      govspeak = <<-GOVSPEAK
[link 1](http://example.org)
[link 2](mailto:email@example.org)
      GOVSPEAK
      GovspeakUrlChecker.new(govspeak).find_broken_links
    end

    it "ignores anchor links" do
      expect(HTTParty).to receive(:get)
        .with("http://example.org", follow_redirects: true, timeout: 5)
        .and_return success

      govspeak = <<-GOVSPEAK
[link 1](http://example.org)
[link 2](#some-heading)
      GOVSPEAK
      GovspeakUrlChecker.new(govspeak).find_broken_links
    end

    it "expires cached urls after 5 minutes" do
      CheckedUrl.create!(
        url: "http://old-url.com",
        code: 500,
        created_at: 6.minutes.ago,
      )
      CheckedUrl.create!(
        url: "http://new-url.com",
        code: 500,
        created_at: 3.minutes.ago,
      )

      expect(HTTParty).to receive(:get)
        .with("http://old-url.com", follow_redirects: true, timeout: 5)
        .once
        .and_return success

      govspeak = <<-GOVSPEAK
[link 1](http://old-url.com)
[link 2](http://new-url.com)
      GOVSPEAK
      GovspeakUrlChecker.new(govspeak).find_broken_links
    end
  end
end
