class TopicSectionGuide < ActiveRecord::Base
  belongs_to :topic_section
  belongs_to :guide

  acts_as_list scope: :topic_section
end
