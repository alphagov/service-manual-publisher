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

      unless edition.notification_subscribers == [user]
        NotificationMailer.published(guide, user).deliver_later
      end

      GuideSearchIndexer.new(guide).index

      ManageResult.new(true, [])
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

  def catching_gds_api_exceptions(&block)
    begin
      ActiveRecord::Base.transaction do
        block.call
      end
    rescue GdsApi::HTTPErrorResponse => e
      ManageResult.new(false, [ e.error_details['error']['message'] ])
    end
  end
end
