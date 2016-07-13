class ServiceStandardSearchIndexer
  def initialize
    @service_standard = ServiceStandardPresenter.new(Point.all).content_payload
  end

  def index
    RUMMAGER_API.add_document(
      # Pretend the service standard is a guide, as far as Rummager's
      # concerned it might as well be.
      'service_manual_guide',
      @service_standard[:base_path],
      'format':            'service_manual_guide',
      'description':       @service_standard[:details][:introduction],
      'indexable_content': @service_standard[:details][:body],
      'title':             @service_standard[:title],
      'link':              @service_standard[:base_path],
      'manual':            '/service-manual',
      'organisations':     ['government-digital-service'],
    )
  end

  def delete
    RUMMAGER_API.delete_content!(@service_standard[:base_path])
  end
end
