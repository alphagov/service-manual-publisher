class GuideForm < BaseGuideForm
  attr_accessor :topic_section_id

  validates_presence_of :topic_section_id, if: :requires_topic?
  validate :topic_cannot_change

  def requires_topic?
    true
  end

  def slug_prefix
    "/service-manual"
  end

private

  def load_custom_attributes
    self.topic_section_id = topic_section.try(:id)
  end

  def set_custom_attributes
    topic_section_guide.topic_section_id = topic_section_id
  end

  def topic_section_guide
    @_topic_section_guide ||=
      guide.topic_section_guides[0] || guide.topic_section_guides.build
  end

  def topic_section
    TopicSection
      .joins(:topic_section_guides)
      .find_by('topic_section_guides.guide_id = ?', guide.id)
  end

  def topic_cannot_change
    from, to = topic_section_guide.topic_section_id_change

    return true if from.blank?

    old_section = TopicSection.find(from)
    new_section = TopicSection.find(to)

    if old_section.topic_id != new_section.topic_id
      errors.add(:topic_section_id, "cannot change to a different topic")
    end
  end
end
