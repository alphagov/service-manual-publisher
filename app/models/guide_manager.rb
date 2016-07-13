class GuideManager
  def initialize(guide:, user:)
    @guide = guide
    @user = user
  end

  def request_review!
    edition = build_clone_of_latest_edition
    edition.state = 'review_requested'
    edition.save!
  end

  def approve_for_publication!
    edition = build_clone_of_latest_edition
    edition.build_approval(user: user)
    edition.state = "ready"
    edition.save!

    NotificationMailer.ready_for_publishing(guide).deliver_later
  end

  def publish
    catching_gds_api_exceptions do
      edition = build_clone_of_latest_edition
      edition.state = 'published'
      edition.save!
      PUBLISHING_API.publish(guide.content_id, edition.update_type)

      if guide.is_a?(Point)
        save_and_publish_the_service_standard
      end

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
      if guide.has_published_edition?
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
      error_message = e.error_details['error']['message'] rescue "Received error #{e.code} from Publishing API"
      ManageResult.new(false, [error_message])
    end
  end

  # Until we can use custom link expansion we need to save a draft and publish the
  # standard whenever we publish a new point.
  #
  # If we save a draft of the service standard when we save a draft of a specific point, the
  # saving of any other point before our point will overwrite the previously created
  # draft. This will confuse the user because they will click "publish" on a point page and the
  # relevant point will not appear in the standard.
  #
  def save_and_publish_the_service_standard
    service_standard_for_publication = ServiceStandardPresenter.new(Point.all)
    PUBLISHING_API.put_content(
      service_standard_for_publication.content_id,
      service_standard_for_publication.content_payload
    )

    PUBLISHING_API.publish(
      ServiceStandardPresenter::SERVICE_STANDARD_CONTENT_ID,
      "major"
    )
  end
end
