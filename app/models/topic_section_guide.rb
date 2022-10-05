class TopicSectionGuide < ApplicationRecord
  belongs_to :topic_section
  belongs_to :guide
  before_create :default_position_to_next_in_list

  # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :guide_id,
            uniqueness: { scope: :topic_section_id,
                          message: "can only be in one topic section" }
  # rubocop:enable Rails/UniqueValidationWithoutIndex

  scope :within_topic_section,
        lambda { |topic_section_id|
          where(topic_section_id:)
        }

private

  def default_position_to_next_in_list
    self.position ||= next_position_in_list
  end

  def next_position_in_list
    highest_position_in_list + 1
  end

  def highest_position_in_list
    TopicSectionGuide.within_topic_section(topic_section_id).maximum(:position) || 0
  end
end
