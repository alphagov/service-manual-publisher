class Generators
  def self.valid_edition(attributes = {})
    content_owner = attributes.delete(:content_owner)

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

  def self.valid_user(attributes = {})
    attrs = { name: "Test User", permissions: ["signin"] }
    attrs.merge!(attributes)
    attrs[:email] ||= "#{attrs[:name].parameterize}@example.com"
    User.new(attrs)
  end
end
