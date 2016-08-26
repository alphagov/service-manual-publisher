class EditionPolicy
  def initialize(user, edition)
    @user = user
    @edition = edition
  end

  def can_request_review?
    edition.persisted? && edition.draft?
  end

  def can_be_approved?
    edition.review_requested? && permission_to_approve?
  end

  def can_be_published?
    edition.ready? && edition.latest_edition?
  end

  def can_discard_draft?
    !Edition::STATES_THAT_UPDATE_THE_FRONTEND.include?(edition.state)
  end

  def can_discard_new_draft?
    edition.new_record?
  end

  def can_preview?
    edition.persisted?
  end

private

  attr_reader :user, :edition

  def permission_to_approve?
    same_user_as_the_author? || allow_self_approval?
  end

  def same_user_as_the_author?
    edition.author != user
  end

  def allow_self_approval?
    ENV['ALLOW_SELF_APPROVAL'].present?
  end
end
