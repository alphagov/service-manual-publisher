class Generators
  def self.valid_edition(attributes = {})
    attributes = {
      title:           "The Title",
      state:           "draft",
      phase:           "beta",
      description:     "Description",
      update_type:     "major",
      change_note:     "change note",
      body:            "# Heading",
      publisher_title: Edition::PUBLISHERS.keys.first,
      user:            User.new(name: "Generated User")
    }.merge(attributes)

    Edition.new(attributes)
  end

  def self.valid_published_edition(attributes = {})
    attributes = {state: "published"}.merge(attributes)
    edition = valid_edition(attributes)
    edition.approvals << Approval.new(user: User.first)
    edition
  end
end
