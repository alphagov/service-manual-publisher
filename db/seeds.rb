if Rails.env.development?
  unless Dir.exist?("../government-service-design-manual")
    print "Cloning repository..."
    sh "cd ../ && git clone https://github.com/alphagov/government-service-design-manual"
    puts " [done]"
  end
  objects = Dir.glob("../government-service-design-manual/service-manual/**/*.md")
  .map do |path|
    url = path.gsub("../government-service-design-manual", "")
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

      next if body.blank?

      edition = Edition.new(
        title:           title,
        state:           state.present? ? state : "draft",
        phase:           "beta",
        description:     "Description",
        update_type:     "major",
        body:            body,
        publisher_title: Edition::PUBLISHERS.keys.first,
        user:            author
      )
      guide = Guide.create!(slug: object[:url], content_id: nil, latest_edition: edition)
      GuidePublisher.new(guide).publish!
    end
  end
end
