class TopicSectionGuide < ActiveRecord::Base
  belongs_to :topic_section
  belongs_to :guide
  before_create :default_position_to_next_in_list

  validates_uniqueness_of :guide_id,
    scope: :topic_section_id,
    message: "can only be in one topic section"

  scope :within_topic_section, ->(topic_section_id) {
    where(topic_section_id: topic_section_id)
  }

  def default_position_to_next_in_list
    self.position ||= next_position_in_list
  end

  def next_position_in_list
    (TopicSectionGuide.within_topic_section(self.topic_section_id).maximum(:position) || 0) + 1
  end
end
