class HomepageSearchIndexer
  def initialize
    @homepage = HomepagePresenter.new.content_payload
  end

  def index
    RUMMAGER_API.add_document(
      # Pretend the homepage is a guide, as far as Rummager's concerned it might
      # as well be.
      'service_manual_guide',
      @homepage[:base_path],
      format:            'service_manual_guide',
      description:       @homepage[:description],
      indexable_content: "",
      title:             @homepage[:title],
      link:              @homepage[:base_path],
      manual:            '/service-manual',
      organisations:     ['government-digital-service'],
    )
  end

  def delete
    RUMMAGER_API.delete_content!(@service_standard[:base_path])
  end
end
