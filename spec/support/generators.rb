class Generators
  def self.valid_edition(attributes = {})
    user = User.new(name: "Generated User")

    review_request = ReviewRequest.new(
      approvals: [Approval.new(user: user)],
    )

    attributes = {
      title:           "The Title",
      state:           "draft",
      phase:           "beta",
      description:     "Description",
      update_type:     "major",
      body:            "# Heading",
      publisher_title: Edition::PUBLISHERS.keys.first,
      user:            user,
      review_request:  review_request,
    }.merge(attributes)

    Edition.new(attributes)
  end
end
