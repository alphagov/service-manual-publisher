class Generators
  def self.valid_edition(attributes = {})
    content_owner = attributes.delete(:content_owner) || valid_community_guide

    attributes = {
      content_owner: content_owner
    }.merge(attributes)

    valid_edition_minus_content_owner(attributes)
  end

  def self.valid_edition_minus_content_owner(attributes = {})
    content_owner = attributes.delete(:content_owner)
    title = attributes.delete(:title) || "The Title"

    attributes = {
      title:          title,
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

  def self.valid_user(attributes = {})
    attrs = { name: "Test User", permissions: ["signin"] }
    attrs.merge!(attributes)
    attrs[:email] ||= "#{attrs[:name].parameterize}@example.com"
    User.new(attrs)
  end

  def self.valid_community_guide(attributes = {})
    editions = attributes.delete(:editions) || [valid_edition_minus_content_owner(title: 'Community Guide')]
    slug = attributes.delete(:slug) || '/service-manual/community-guide'

    attributes = {
      community: true,
      editions: editions,
      slug: slug
    }.merge(attributes)

    Guide.new(attributes)
  end
end
