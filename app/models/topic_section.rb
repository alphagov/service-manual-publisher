class TopicSection < ApplicationRecord
  belongs_to :topic

  has_many :topic_section_guides, -> { order(position: :asc) }, dependent: :destroy
  accepts_nested_attributes_for :topic_section_guides

  has_many :guides, through: :topic_section_guides
end
