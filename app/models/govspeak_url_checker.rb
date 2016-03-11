class GovspeakUrlChecker
  def initialize govspeak
    @govspeak = govspeak
  end

  def find_broken_urls
    extract_all_urls_from_govspeak.select do |url|
      checked_url = CheckedUrl.find_or_initialize_by(url: url)
      if checked_url.new_record? || checked_url.expired?
        checked_url.ok = check_url(url)
        checked_url.save!
      end

      !checked_url.ok?
    end
  end

  private

    def check_url url
      options = {
        follow_redirects: true,
        timeout: 5,
      }

      if url.starts_with? "/"
        url = "#{Plek.new.website_root}#{url}"
        if ENV["HTTP_USERNAME"] && ENV["HTTP_PASSWORD"]
          options[:basic_auth] = {
            username: ENV["HTTP_USERNAME"],
            password: ENV["HTTP_PASSWORD"],
          }
        end
      end

      begin
        HTTParty.get(
          url,
          options,
        ).ok?
      rescue
        false
      end
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
