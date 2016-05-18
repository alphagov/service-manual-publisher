class TopicSectionGuide < ActiveRecord::Base
  belongs_to :topic_section
  belongs_to :guide

  acts_as_list scope: :topic_section

  validates_uniqueness_of :guide_id,
    scope: :topic_section_id,
    message: "can only be in one topic section"
end
