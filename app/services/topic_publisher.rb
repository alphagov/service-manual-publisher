class TopicPublisher
  attr_reader :topic, :publishing_api

  def initialize(topic:, publishing_api: PUBLISHING_API)
    @topic = topic
    @publishing_api = publishing_api
  end

  def save_draft
    topic_presenter = TopicPresenter.new(topic)

    save_catching_gds_api_errors do
      publishing_api.put_content(topic_presenter.content_id, topic_presenter.content_payload)
      publishing_api.patch_links(topic_presenter.content_id, topic_presenter.links_payload)
    end
  end

  def publish
    save_catching_gds_api_errors do
      publishing_api.publish(topic.content_id)
    end
  end

private

  def save_catching_gds_api_errors
    ApplicationRecord.transaction do
      if topic.save
        yield

        Response.new(success: true)
      else
        Response.new(success: false)
      end
    end
  rescue GdsApi::HTTPErrorResponse => e
    GovukError.notify(e)
    error_message = begin
                      e.error_details["error"]["message"]
                    rescue StandardError
                      "Could not communicate with upstream API"
                    end
    Response.new(success: false, error: error_message)
  end

  class Response
    def initialize(options = {})
      @success = options.fetch(:success)
      @error = options[:error]
    end

    def success?
      @success
    end

    attr_reader :error
  end
end
