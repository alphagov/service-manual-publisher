require 'rails_helper'

RSpec.describe GovspeakUrlChecker do
  include WebMock::API

  describe "#find_broken_urls" do
    before do
      WebMock.disable_net_connect!
      WebMock.reset!
    end

    after do
      WebMock.allow_net_connect!
    end

    it "lists broken links" do
      stub_request(:get, "http://example.org/one").to_return(status: 200)
      stub_request(:get, "http://example.org/two").to_return(status: 500)

      govspeak = <<-GOVSPEAK
[link 1](http://example.org/one)
[link 2](http://example.org/two)
      GOVSPEAK
      broken_urls = GovspeakUrlChecker.new(govspeak).find_broken_urls
      expect(broken_urls).to eq ["http://example.org/two"]
    end

    it "caches already checked urls" do
      stub_request(:get, "http://some-url.com/url").to_return(status: 200)
      govspeak = "[link](http://some-url.com/url)"
      GovspeakUrlChecker.new(govspeak).find_broken_urls
      GovspeakUrlChecker.new(govspeak).find_broken_urls
    end

    it "rewrites relative urls" do
      stub_request(:get, "http://www.dev.gov.uk/service-manual/agile").to_return(status: 200)
      govspeak = "[link](/service-manual/agile)"
      expect(GovspeakUrlChecker.new(govspeak).find_broken_urls).to eq []
    end

    context "with HTTP_USERNAME and HTTP_PASSWORD" do
      before do
        ENV["HTTP_USERNAME"] = "username"
        ENV["HTTP_PASSWORD"] = "password"
      end

      after do
        ENV.delete("HTTP_USERNAME")
        ENV.delete("HTTP_PASSWORD")
      end

      it "uses basic auth for relative urls" do
        expected_url = "http://username:password@www.dev.gov.uk/service-manual/agile"
        stub_request(:get, expected_url).to_return(status: 200)
        govspeak = "[link](/service-manual/agile)"
        expect(GovspeakUrlChecker.new(govspeak).find_broken_urls).to eq []
      end
    end

    it "ignores mailto: links" do
      stub_request(:get, "http://example.org").to_return(status: 200)
      govspeak = <<-GOVSPEAK
[link 1](http://example.org)
[link 2](mailto:email@example.org)
      GOVSPEAK
      GovspeakUrlChecker.new(govspeak).find_broken_urls
    end

    it "ignores anchor links" do
      stub_request(:get, "http://example.org").to_return(status: 200)
      govspeak = <<-GOVSPEAK
[link 1](http://example.org)
[link 2](#some-heading)
      GOVSPEAK
      GovspeakUrlChecker.new(govspeak).find_broken_urls
    end

    it "expires cached urls after 5 minutes" do
      create(
        :broken_checked_url,
        url: "http://old-url.com",
        created_at: 6.minutes.ago,
      )
      create(
        :ok_checked_url,
        url: "http://new-url.com",
        created_at: 3.minutes.ago,
      )

      stub_request(:get, "http://old-url.com")
        .to_return(status: 200)
        .times(1)

      govspeak = <<-GOVSPEAK
[link 1](http://old-url.com)
[link 2](http://new-url.com)
      GOVSPEAK
      GovspeakUrlChecker.new(govspeak).find_broken_urls
    end

    it "lists links that httparty raises on" do
      govspeak = "[link](something://url.com)"
      result = GovspeakUrlChecker.new(govspeak).find_broken_urls
      expect(result).to include "something://url.com"
    end

    it "sets a timeout" do
      expect(HTTParty).to receive(:get).with(
        anything, hash_including(timeout: 5)
      )
      govspeak = "[link](http://example.org)"
      GovspeakUrlChecker.new(govspeak).find_broken_urls
    end

    it "follows redirects" do
      expect(HTTParty).to receive(:get).with(
        anything, hash_including(follow_redirects: true)
      )
      govspeak = "[link](http://example.org)"
      GovspeakUrlChecker.new(govspeak).find_broken_urls
    end
  end
end
