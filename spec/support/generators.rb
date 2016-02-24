class Generators
  def self.valid_edition(attributes = {})
    default_content_owner = GuideCommunity.first || ContentOwner.create(title: "content owner title", href: "content_owner_href")
    content_owner = attributes.fetch(:content_owner, default_content_owner)

    attributes = {
      title:          "The Title",
      state:          "draft",
      phase:          "beta",
      description:    "Description",
      update_type:    "major",
      change_note:    "change note",
      change_summary: "change summary",
      body:           "# Heading",
      content_owner:  content_owner,
      user:           valid_user,
    }.merge(attributes)

    Edition.new(attributes)
  end

  def self.valid_published_edition(attributes = {})
    attributes = {state: "published"}.merge(attributes)
    edition = valid_edition(attributes)
    edition.create_approval(user: User.first)
    edition
  end

  def self.valid_approved_edition(attributes = {})
    attributes = {state: "approved"}.merge(attributes)
    edition = valid_edition(attributes)
    edition.create_approval(user: User.first)
    edition
  end

  def self.valid_guide(attributes = {})
    default_attributes = { slug: "/service-manual/test-guide#{SecureRandom.hex}" }
    Guide.new(default_attributes.merge(attributes))
  end

  def self.valid_guide_community(attributes = {})
    default_attributes = { slug: "/service-manual/test-guide#{SecureRandom.hex}" }
    GuideCommunity.new(default_attributes.merge(attributes))
  end

  def self.valid_user(attributes = {})
    attrs = { name: "Test User", permissions: ["signin"] }
    attrs.merge!(attributes)
    attrs[:email] ||= "#{attrs[:name].parameterize}@example.com"
    User.new(attrs)
  end

  def self.create_valid_topic!(attributes = {})
    topic = valid_topic(attributes)
    topic.save!
    topic
  end

  def self.valid_topic(attributes = {})
    attrs = { title: "Agile Delivery", path: "/service-manual/agile-delivery", description: "Agile description" }
    attrs.merge!(attributes)
    Topic.new(attrs)
  end
end
