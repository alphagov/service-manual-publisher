class ApprovalProcess
  attr_reader :content_model, :user

  def initialize(content_model:, user:)
    @content_model = content_model
    @user = user
  end

  def request_review
    next_edition.state = 'review_requested'
    next_edition.created_by = user
    next_edition.save!
  end

  def give_approval
    next_edition.build_approval(user: user)
    next_edition.created_by = user
    next_edition.state = "ready"
    next_edition.save!

    NotificationMailer.ready_for_publishing(content_model).deliver_later
  end

private

  def next_edition
    @_next_edition ||= @content_model.editions.detect(&:new_record?)
  end
end
