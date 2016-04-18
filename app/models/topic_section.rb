class TopicSection < ActiveRecord::Base
  belongs_to :topic
  has_many :guides, through: :topic_section_guides
  has_many :topic_section_guides, -> { order(position: :asc) }, dependent: :destroy
  acts_as_list scope: :topic
end
