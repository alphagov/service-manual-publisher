class GovspeakUrlChecker
  def initialize govspeak
    @govspeak = govspeak
  end

  def find_broken_urls
    urls_to_check = extract_all_urls_from_govspeak.select do |url|
      url = CheckedUrl.find_or_initialize_by(url: url)
      url.new_record? || url.expired?
    end

    if urls_to_check.any?
      broken_urls = check_urls(urls_to_check)
      urls_to_check.each do |url|
        CheckedUrl.find_or_initialize_by(url: url) do |checked_url|
          checked_url.ok = !broken_urls.include?(checked_url.url)
        end.save!
      end
      broken_urls
    else
      []
    end
  end

  private

  def check_urls urls
    EventMachine.run {
      multi = EventMachine::MultiRequest.new

      urls.each_with_index do |url, index|
        options = {
          connect_timeout: 1,
          inactivity_timeout: 5,
          redirects: 3,
        }
        if url.starts_with? "/"
          url = "#{Plek.new.website_root}#{url}"
          if ENV["HTTP_USERNAME"] && ENV["HTTP_PASSWORD"]
            options[:head] = {
              "authorization" => [
                ENV["HTTP_USERNAME"],
                ENV["HTTP_PASSWORD"],
              ]
            }
          end
        end

        http = EventMachine::HttpRequest.new(url, options)
        request = http.get
        multi.add index, request
      end
      multi.callback do
        broken_urls = []
        urls.each_with_index do |url, index|
          ok = multi.responses[:callback][index].response_header.successful?
          broken_urls << url if !ok
        end
        EventMachine.stop
        return broken_urls
      end
    }
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
