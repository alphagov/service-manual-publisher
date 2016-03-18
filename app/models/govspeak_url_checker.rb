class GovspeakUrlChecker
  def initialize govspeak
    @govspeak = govspeak
  end

  def find_broken_urls
    urls_to_check = extract_all_urls_from_govspeak.select do |url|
      url = CheckedUrl.find_or_initialize_by(url: url)
      url.new_record? || url.expired?
    end

    broken_urls = check_urls(urls_to_check)
    urls_to_check.each do |url|
      CheckedUrl.find_or_create_by(url: url) do |checked_url|
        checked_url.ok = broken_urls.exclude?(checked_url.url)
      end
    end
    broken_urls
  end

  private

  def check_urls urls
    broken_urls = []
    hydra = Typhoeus::Hydra.new

    urls.each do |url|
      options = {
        followlocation: true,
        forbid_reuse: true,
        timeout: 10,
        connecttimeout: 10,
      }

      if url.starts_with? "/"
        url = "#{Plek.new.website_root}#{url}"
        if ENV["HTTP_USERNAME"] && ENV["HTTP_PASSWORD"]
          options[:userpwd] = "#{ENV["HTTP_USERNAME"]}:#{ENV["HTTP_PASSWORD"]}"
        end
      end

      begin
        Addressable::URI.parse(url)
      rescue URI::InvalidURIError, Addressable::URI::InvalidURIError
        broken_urls << url
        next
      end

      request = Typhoeus::Request.new(url, options)
      request.on_failure do |response|
        broken_urls << url
      end

      hydra.queue request
    end
    hydra.run

    broken_urls
  end

    def extract_all_urls_from_govspeak
      govspeak_document = Govspeak::Document.new(@govspeak)
      nokogiri_document = Nokogiri::HTML::Document.new
      nokogiri_document.encoding = "UTF-8"
      nokogiri_fragment = nokogiri_document.fragment(govspeak_document.to_html)
      nokogiri_fragment
        .css('a:not([href^="mailto"])')
        .css('a:not([href^="#"])')
        .map { |link| link['href'] }
    end
end
