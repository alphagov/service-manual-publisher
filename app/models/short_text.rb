class ShortText
  include ActiveModel::Model

  attr_accessor :slug
  attr_accessor :title
  attr_accessor :body
  attr_accessor :base_path
  attr_accessor :content_id
  attr_accessor :description
  attr_accessor :format
  attr_accessor :need_ids
  attr_accessor :locale
  attr_accessor :updated_at
  attr_accessor :public_updated_at
  attr_accessor :details
  attr_accessor :phase
  attr_accessor :analytics_identifier
  attr_accessor :links
end
