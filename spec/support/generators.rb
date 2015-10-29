class Generators
  def self.valid_edition(attributes = {})
    user = User.new(name: "Generated User")

    attributes = {
      title:           "The Title",
      state:           "draft",
      phase:           "beta",
      description:     "Description",
      update_type:     "major",
      body:            "# Heading",
      publisher_title: Edition::PUBLISHERS.keys.first,
      user:            user,
      approvals:       [Approval.new(user: user)],
    }.merge(attributes)

    Edition.new(attributes)
  end
end
