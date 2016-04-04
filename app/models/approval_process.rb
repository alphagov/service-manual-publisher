class ApprovalProcess
  attr_reader :content_model

  def initialize(content_model:)
    @content_model = content_model
  end

  def request_review
    next_edition = content_model.latest_edition.dup
    next_edition.state = 'review_requested'
    next_edition.save!
  end

  def give_approval(approver:)
    edition = content_model.latest_edition
    edition.build_approval(user: approver)
    edition.state = "ready"
    edition.save!

    NotificationMailer.ready_for_publishing(content_model).deliver_later
  end
end
