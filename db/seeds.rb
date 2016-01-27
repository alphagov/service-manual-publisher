require "English"

def all_old_guides
  directory = File.join(Dir.tmpdir, "government-service-design-manual", "git")
  unless Dir.exist?(directory)
    print "Cloning repository..."
    sh "git clone --depth 1 https://github.com/alphagov/government-service-design-manual #{directory}"
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
  yaml_front_matter_regexp = /\A(---\s*\n.*?\n?)^((---|\.\.\.)\s*$\n?)/m

  objects.map do |o|
    content = File.read(o[:path])
    title = ""

    if content =~ yaml_front_matter_regexp
      body = $POSTMATCH
      data_file = YAML.load($1)
      title = data_file["title"]
      state = data_file["status"] || "draft"
      {
        url: o[:url],
        path: o[:path],
        title: title,
        state: state,
        body: body,
      }
    end
  end

end

if Rails.env.development? || ENV["GOVUK_APP_DOMAIN"] == "preview.alphagov.co.uk"
  author = User.first || User.create!(name: "Unknown", email: "unknown@example.com")
  if Guide.community_guides.empty?
    Guide.create!(
      community: true,
      latest_edition: Generators.valid_edition(title: 'Design Community'),
      slug: "/service-manual/design-community"
    )
  end

  objects = all_old_guides

  objects.each do |object|
    if Guide.find_by_slug(object[:url]).present?
      next
      puts "Ignoring '#{object[:title]}'"
    end
    puts "Creating '#{object[:title]}'"

    if object[:body].blank?
      puts "Body is blank, skipping..."
      next
    end

    edition = Edition.new(
      title:           object[:title],
      state:           object[:state],
      phase:           "beta",
      description:     "Description",
      update_type:     "minor",
      body:            object[:body].gsub(/\n/, "\r\n"),
      content_owner:   Guide.community_guides.first,
      user:            author,
    )
    guide = Guide.create!(slug: object[:url], content_id: nil, latest_edition: edition)

    GuidePublisher.new(guide: guide).put_draft
    if object[:state] == "published" && !Rails.env.production?
      GuidePublisher.new(guide: guide).publish
    end
  end
end
