class Publisher
  attr_reader :content_model, :publishing_api

  def initialize(content_model:, publishing_api: PUBLISHING_API)
    @content_model = content_model
    @publishing_api = publishing_api
  end

  def save_draft(content_for_publication)
    save_catching_gds_api_errors do
      publishing_api.put_content(content_model.content_id, content_for_publication.exportable_attributes)
    end
  end

  def publish
    save_catching_gds_api_errors do
      publishing_api.publish(content_model.content_id, content_model.latest_edition.update_type)
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

  class PublicationResponse
    attr_reader :success, :errors

    alias_method :success?, :success

    def initialize(opts = {})
      @success = opts.fetch(:success)
      @errors = opts.fetch(:errors, [])
    end
  end
end
