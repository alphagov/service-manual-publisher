class TopicSection < ActiveRecord::Base
  belongs_to :topic
  has_many :guides, through: :topic_section_guides
  before_create :default_position_to_next_in_list

  has_many :topic_section_guides, -> { order(position: :asc) }, dependent: :destroy
  accepts_nested_attributes_for :topic_section_guides

  scope :belonging_to_topic, ->(topic_id) {
    where(topic_id: topic_id)
  }

  def default_position_to_next_in_list
    self.position ||= next_position_in_list
  end

  def next_position_in_list
    (TopicSection.belonging_to_topic(self.topic_id).maximum(:position) || 0) + 1
  end
end
