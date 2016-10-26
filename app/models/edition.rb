class Edition < ActiveRecord::Base
  STATES = %w(draft published review_requested ready unpublished).freeze
  STATES_THAT_UPDATE_THE_FRONTEND = %w(published unpublished).freeze

  belongs_to :guide, touch: true
  belongs_to :author, class_name: "User"
  belongs_to :created_by, class_name: "User"

  has_many :comments, as: :commentable

  has_one :approval

  belongs_to :content_owner, class_name: 'GuideCommunity'

  scope :draft, -> { where(state: 'draft') }
  scope :published, -> { where(state: 'published') }
  scope :unpublished, -> { where(state: 'unpublished') }
  scope :review_requested, -> { where(state: 'review_requested') }
  scope :most_recent_first, -> { order('created_at DESC, id DESC') }
  scope :which_update_the_frontend, -> { where(state: STATES_THAT_UPDATE_THE_FRONTEND) }

  scope :major, -> { where(update_type: 'major') }

  validates_presence_of [:state, :phase, :description, :title, :update_type, :body, :author]
  validates_inclusion_of :state, in: STATES
  validates_inclusion_of :update_type, in: ['major'], if: :first_version?, message: 'must be major'
  validates :reason_for_change, presence: true, if: :major_and_not_first_version?
  validates :change_note, presence: true, if: :major?
  validates :version, presence: true
  validates :created_by, presence: true
  validate :cannot_make_a_draft_for_a_published_version

  auto_strip_attributes(
    :title,
    :description,
    :body,
  )

  %w{minor major}.each do |s|
    define_method "#{s}?" do
      update_type == s
    end
  end

  STATES.each do |s|
    define_method "#{s}?" do
      state == s
    end
  end

  def latest_edition?
    self == guide.latest_edition
  end

  def content_owner_title
    content_owner.try(:title)
  end

  def previously_published_edition
    @previously_published_edition ||= guide.editions.published.where("id < ?", id).order(id: :desc).first
  end

  def notification_subscribers
    [author, guide.latest_edition.author].uniq
  end

private

  def major_and_not_first_version?
    major? && !first_version?
  end

  def first_version?
    (version || 1) == 1
  end

  def cannot_make_a_draft_for_a_published_version
    return unless state == 'draft'

    scope = self.class.published.where(guide_id: guide_id, version: version)

    if scope.any?
      errors.add(:version, 'has already been published')
    end
  end
end
