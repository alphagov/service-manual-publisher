class EditionPolicy
  def initialize(user, edition)
    @user = user
    @edition = edition
  end

  def can_request_review?
    return false if edition.new_record?

    edition.draft?
  end

  def can_be_approved?
    return false if edition.new_record?

    edition.review_requested? && permission_to_approve?
  end

  def can_be_published?
    return false if edition.new_record?

    edition.ready? && edition.latest_edition?
  end

  def can_discard_draft?
    return false if edition.new_record?

    !Edition::STATES_THAT_UPDATE_THE_FRONTEND.include?(edition.state)
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
