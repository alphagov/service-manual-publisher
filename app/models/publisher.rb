class Publisher
  attr_reader :content_model

  def initialize(content_model:)
    @content_model = content_model
  end

  def save_draft
    content_model.save
  end
end
