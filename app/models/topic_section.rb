class TopicSection < ActiveRecord::Base
  belongs_to :topic
  has_many :guides, through: :topic_section_guides

  has_many :topic_section_guides, -> { order(position: :asc) }, dependent: :destroy
  accepts_nested_attributes_for :topic_section_guides

  scope :belonging_to_topic, ->(topic_id) {
    where(topic_id: topic_id)
  }
end
