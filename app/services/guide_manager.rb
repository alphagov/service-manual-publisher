class GuideManager
  def initialize(guide:, user:)
    @guide = guide
    @user = user
  end

  def request_review!
    edition = build_clone_of_latest_edition
    edition.state = "review_requested"
    edition.save!

    ManageResult.new(true, [])
  end

  def approve_for_publication!
    edition = build_clone_of_latest_edition
    edition.build_approval(user: user)
    edition.state = "ready"
    edition.save!

    NotificationMailer.ready_for_publishing(guide).deliver_now

    ManageResult.new(true, [])
  end

  def publish
    catching_gds_api_exceptions do
      edition = build_clone_of_latest_edition
      edition.state = "published"
      edition.save!
      PUBLISHING_API.publish(guide.content_id)

      unless edition.notification_subscribers == [user]
        NotificationMailer.published(guide, user).deliver_now
      end

      ManageResult.new(true, [])
    end
  end

  def unpublish_with_redirect(destination)
    redirect = Redirect.new(
      old_path: guide.slug,
      new_path: destination,
    )

    catching_gds_api_exceptions do
      if redirect.save
        edition = build_clone_of_latest_edition
        edition.state = "unpublished"
        edition.save!

        PUBLISHING_API.unpublish(
          guide.content_id,
          type: "redirect",
          alternative_path: redirect.new_path,
        )

        ManageResult.new(true, [])
      else
        ManageResult.new(false, redirect.errors.full_messages)
      end
    end
  end

  def discard_draft
    catching_gds_api_exceptions do
      if guide.has_any_published_editions?
        guide
          .editions_since_last_published
          .destroy_all
      else
        guide.destroy!
      end

      PUBLISHING_API.discard_draft(guide.content_id)

      ManageResult.new(true, [])
    end
  end

private

  attr_reader :guide, :user

  ManageResult = Struct.new(:success, :errors) do
    alias_method :success?, :success
  end

  def build_clone_of_latest_edition
    guide.editions.build(guide.latest_edition.dup.attributes).tap do |edition|
      edition.created_by = user
    end
  end

  def catching_gds_api_exceptions
    ApplicationRecord.transaction do
      yield
    end
  rescue GdsApi::HTTPErrorResponse => e
    GovukError.notify(e)
    error_message = begin
                      e.error_details["error"]["message"]
                    rescue StandardError
                      "Could not communicate with upstream API"
                    end
    ManageResult.new(false, [error_message])
  end
end
