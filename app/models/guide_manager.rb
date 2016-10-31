class GuideManager
  def initialize(guide:, user:)
    @guide = guide
    @user = user
  end

  def request_review!
    edition = build_clone_of_latest_edition
    edition.state = 'review_requested'
    edition.save!

    ManageResult.new(true, [])
  end

  def approve_for_publication!
    edition = build_clone_of_latest_edition
    edition.build_approval(user: user)
    edition.state = "ready"
    edition.save!

    NotificationMailer.ready_for_publishing(guide).deliver_later

    ManageResult.new(true, [])
  end

  def publish
    catching_gds_api_exceptions do
      edition = build_clone_of_latest_edition
      edition.state = 'published'
      edition.save!
      PUBLISHING_API.publish(guide.content_id, edition.update_type)

      unless edition.notification_subscribers == [user]
        NotificationMailer.published(guide, user).deliver_later
      end

      GuideSearchIndexer.new(guide).index

      ManageResult.new(true, [])
    end
  end

  def unpublish_with_redirect(destination)
    redirect = Redirect.new(
      old_path: guide.slug,
      new_path: destination
    )

    catching_gds_api_exceptions do
      if redirect.save
        edition = build_clone_of_latest_edition
        edition.state = "unpublished"
        edition.save!

        PUBLISHING_API.unpublish(guide.content_id,
          type: 'redirect',
          alternative_path: redirect.new_path
        )

        begin
          GuideSearchIndexer.new(guide).delete
        rescue GdsApi::HTTPNotFound => exception
          Airbrake.notify(exception)
        end

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
    begin
      ActiveRecord::Base.transaction do
        yield
      end
    rescue GdsApi::HTTPErrorResponse => e
      Airbrake.notify(e)
      error_message = e.error_details['error']['message'] rescue "Could not communicate with upstream API"
      ManageResult.new(false, [error_message])
    end
  end
end
