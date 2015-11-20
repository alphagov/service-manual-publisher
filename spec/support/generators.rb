class Generators
  def self.valid_edition(attributes = {})
    content_owner = ContentOwner.first || ContentOwner.create(title: "content owner title", href: "content_owner_href")

    attributes = {
      title:         "The Title",
      state:         "draft",
      phase:         "beta",
      description:   "Description",
      update_type:   "major",
      change_note:   "change note",
      body:          "# Heading",
      content_owner: content_owner,
      user:          User.new(name: "Generated User")
    }.merge(attributes)

    Edition.new(attributes)
  end

  def self.valid_published_edition(attributes = {})
    attributes = {state: "published"}.merge(attributes)
    edition = valid_edition(attributes)
    edition.create_approval(user: User.first)
    edition
  end
end
