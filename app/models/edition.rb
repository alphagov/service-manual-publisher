class Edition < ActiveRecord::Base
  PUBLISHERS = {
    "Design Community" => "http://sm-11.herokuapp.com/designing-services/design-community/",
    "Agile Community" => "http://sm-11.herokuapp.com/agile-delivery/agile-community"
  }.freeze

  belongs_to :guide, touch: true
  belongs_to :user

  has_many :approvals

  scope :draft, -> { where(state: 'draft') }
  scope :published, -> { where(state: 'published') }
  scope :review_requested, -> { where(state: 'review_requested') }

  validates_presence_of [:state, :phase, :description, :title, :update_type, :body, :publisher_title, :publisher_href, :user]
  validates_inclusion_of :state, in: %w(draft published review_requested approved)

  before_validation :assign_publisher_href

  def draft?
    state == 'draft'
  end

  def published?
    state == 'published'
  end

  def review_requested?
    state == 'review_requested'
  end

  def approved?
    state == 'approved'
  end

  def copyable_attributes(extra_attributes = {})
    attributes.with_indifferent_access.except('id', 'updated_at', 'created_at').merge(extra_attributes)
  end

  def unsaved_copy
    self.class.new(copyable_attributes)
  end

private

  def assign_publisher_href
    self.publisher_href = PUBLISHERS[publisher_title] if publisher_title.present?
  end
end
