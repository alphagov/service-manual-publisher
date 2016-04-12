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

        if content_model.has_published_edition?
          content_model
            .editions_since_last_published
            .destroy_all
        else
          content_model.destroy!
        end
      end
      Response.new(success: true)
    rescue GdsApi::HTTPErrorResponse => e
      Response.new(success: false, error: e.error_details['error']['message'])
    end
  end

private

  def save_catching_gds_api_errors(&block)
    begin
      ActiveRecord::Base.transaction do
        if content_model.save
          block.call

          Response.new(success: true)
        else
          Response.new(success: false)
        end
      end
    rescue GdsApi::HTTPErrorResponse => e
      Response.new(success: false, error: e.error_details['error']['message'])
    end
  end

  class Response
    def initialize(opts = {})
      @success = opts.fetch(:success)
      @error = opts.fetch(:error, nil)
    end

    def success?
      @success
    end

    def error
      @error
    end
  end
end
