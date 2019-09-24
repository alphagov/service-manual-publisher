class GuideForm < BaseGuideForm
  attr_accessor :topic_section_id

  def slug_prefix
    "/service-manual"
  end

private

  def load_custom_attributes
    self.topic_section_id = topic_section.try(:id)
  end

  def set_custom_attributes
    if topic_section_id.present?
      topic_section_guide.topic_section_id = topic_section_id
    end
  end

  def topic_section_guide
    @_topic_section_guide ||=
      guide.topic_section_guides[0] || guide.topic_section_guides.build
  end

  def topic_section
    TopicSection
      .joins(:topic_section_guides)
      .find_by("topic_section_guides.guide_id = ?", guide.id)
  end
end
