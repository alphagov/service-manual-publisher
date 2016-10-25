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
    is_being_edited?
  end

  def can_discard_new_draft?
    edition.new_record?
  end

  def can_preview?
    edition.persisted? && is_being_edited?
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

  def is_being_edited?
    !Edition::STATES_THAT_UPDATE_THE_FRONTEND.include?(edition.state)
  end
end
