class Generators
  def self.valid_edition(attributes = {})
    attributes = {
      title:           "The Title",
      state:           "draft",
      phase:           "beta",
      description:     "Description",
      update_type:     "major",
      body:            "# Heading",
      publisher_title: Edition::PUBLISHERS.keys.first,
      user:            User.new(name: "Generated User")
    }.merge(attributes)

    Edition.new(attributes)
  end
end
