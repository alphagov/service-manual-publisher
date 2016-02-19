class Publisher
  attr_reader :content_model, :publishing_api

  def initialize(content_model:, publishing_api: PUBLISHING_API)
    @content_model = content_model
    @publishing_api = publishing_api
  end

  def save_draft
    begin
      ActiveRecord::Base.transaction do
        if content_model.save
          publishing_api.put_content(content_model.content_id, {})
        end
      end
    rescue GdsApi::HTTPErrorResponse
    end
  end
end
