class Publisher
  attr_reader :content_model, :publishing_api

  def initialize(content_model:, publishing_api: PUBLISHING_API)
    @content_model = content_model
    @publishing_api = publishing_api
  end

  def save_draft(content_for_publication)
    save_catching_gds_api_errors do
      publishing_api.put_content(content_model.content_id, content_for_publication.content_payload)
      publishing_api.patch_links(content_model.content_id, content_for_publication.links_payload)
    end
  end

  def publish
    save_catching_gds_api_errors do
      publishing_api.publish(content_model.content_id, content_model.latest_edition.update_type)
    end
  end

  def discard_draft
    begin
      ActiveRecord::Base.transaction do
        publishing_api.discard_draft(content_model.content_id)

        latest_published_edition = content_model.editions.published.last
        if latest_published_edition.present?
          content_model
            .editions
            .where("created_at > ?", latest_published_edition.created_at)
            .destroy_all
        else
          content_model.destroy!
        end
      end
      DiscardDraftResponse.new(success: true)
    rescue GdsApi::HTTPErrorResponse => e
      DiscardDraftResponse.new(success: false, errors: e.error_details['error']['message'])
    end
  end

private

  def save_catching_gds_api_errors(&block)
    begin
      ActiveRecord::Base.transaction do
        if content_model.save
          block.call

          PublicationResponse.new(success: true)
        else
          PublicationResponse.new(success: false)
        end
      end
    rescue GdsApi::HTTPErrorResponse => e
      PublicationResponse.new(success: false, errors: e.error_details['error']['message'])
    end
  end

  class DiscardDraftResponse
    def initialize(opts = {})
      @success = opts.fetch(:success)
      @errors = opts.fetch(:errors, [])
    end

    def success?
      @success
    end

    def errors
      @errors
    end
  end

  class PublicationResponse
    attr_reader :success, :errors

    alias_method :success?, :success

    def initialize(opts = {})
      @success = opts.fetch(:success)
      @errors = opts.fetch(:errors, [])
    end
  end
end
