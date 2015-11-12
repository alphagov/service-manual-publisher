require "English"

if Rails.env.development? || ENV["GOVUK_APP_DOMAIN"] == "preview.alphagov.co.uk"
  directory = File.join(Dir.mktmpdir("government-service-design-manual"), "git")
  unless Dir.exist?(directory)
    print "Cloning repository..."
    sh "git clone https://github.com/alphagov/government-service-design-manual #{directory}"
    puts " [done]"
  end

  objects = Dir.glob("#{directory}/service-manual/**/*.md")
  .map do |path|
    url = path.gsub(directory, "")
    url = url.gsub(".md", "")
    url = url.gsub(/\/index$/, '')
    {
      path: path,
      url: url,
    }
  end

  # https://github.com/jekyll/jekyll/blob/2807b8a012ead8b8fe7ed30f1a8ad1f6f9de7ba4/lib/jekyll/document.rb
  YAML_FRONT_MATTER_REGEXP = /\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)/m

  author = User.first || User.create!(name: "Unknown")

  objects.each do |object|
    content = File.read(object[:path])
    title = ""

    if content =~ YAML_FRONT_MATTER_REGEXP
      body = $POSTMATCH
      data_file = YAML.load($1)
      title = data_file["title"]
      state = data_file["status"]

      if Guide.find_by_slug(object[:url]).present?
        next
        puts "Ignoring '#{title}'"
      end
      puts "Creating '#{title}'"

      if body.blank?
        puts "Body is blank, skipping."
        next
      end

      edition = Edition.new(
        title:           title,
        state:           state.present? ? state : "draft",
        phase:           "alpha",
        description:     "Description",
        update_type:     "minor",
        body:            body,
        publisher_title: Edition::PUBLISHERS.keys.first,
        user:            author
      )
      guide = Guide.create!(slug: object[:url], content_id: nil, latest_edition: edition)

      GuidePublisher.new(guide: guide).put_draft
      if state == "published" && !Rails.env.production?
        GuidePublisher.new(guide: guide).publish
      end
    end
  end
end
