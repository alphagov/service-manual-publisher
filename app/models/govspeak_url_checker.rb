class GovspeakUrlChecker
  def initialize govspeak
    @govspeak = govspeak
  end

  def find_broken_links
    govspeak_document = Govspeak::Document.new(@govspeak)

    nokogiri_document = Nokogiri::HTML::Document.new
    nokogiri_document.encoding = "UTF-8"
    nokogiri_fragment = nokogiri_document.fragment(govspeak_document.to_html)
    links = nokogiri_fragment
      .css('a:not([href^="mailto"])')
      .css('a:not([href^="#"])')
      .map { |link| link['href'] }
    links.select do |link|
      checked_url = CheckedUrl.find_or_initialize_by(url: link)
      if checked_url.persisted? == false || checked_url.created_at < 5.minutes.ago
        response = HTTParty.get(
          link,
          follow_redirects: true,
          timeout: 5,
        )
        checked_url.code = response.code
        checked_url.save!
      end

      checked_url.code != 200
    end
  end
end
