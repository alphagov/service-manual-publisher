class Edition < ActiveRecord::Base
  STATES = %w(draft published review_requested ready).freeze

  acts_as_commentable

  belongs_to :guide, touch: true
  belongs_to :user

  has_one :approval

  belongs_to :content_owner, class_name: 'GuideCommunity'

  scope :draft, -> { where(state: 'draft') }
  scope :published, -> { where(state: 'published') }
  scope :review_requested, -> { where(state: 'review_requested') }
  scope :most_recent_first, -> { order('created_at DESC, id DESC') }

  validates_presence_of [:state, :phase, :description, :title, :update_type, :body, :user]
  validates_inclusion_of :state, in: STATES
  validates :change_note, presence: true, if: :major?
  validates :change_summary, presence: true, if: :major?

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

  def draft?
    state == 'draft'
  end

  def published?
    state == 'published'
  end

  def review_requested?
    state == 'review_requested'
  end

  def can_request_review?
    return false if !persisted?
    return false if review_requested?
    return false if published?
    return false if ready?
    true
  end

  def can_be_approved?(by_user)
    return false if new_record?
    return false unless review_requested?
    user != by_user || ENV['ALLOW_SELF_APPROVAL'].present?
  end

  def can_be_published?
    return false if published?
    return false if !latest_edition?
    ready?
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

  def change_note_html
    Redcarpet::Markdown.new(
      Redcarpet::Render::HTML,
      extensions = {
        autolink: true,
      },
    ).render(change_note)
  end

  def draft_copy
    dup.tap do |e|
      e.change_note = nil
      e.update_type = "minor"
      e.state = "draft"
    end
  end

  def notification_subscribers
    [user, guide.latest_edition.user].uniq
  end

  def author
    user
  end

private

  def assign_publisher_href
    self.publisher_href = PUBLISHERS[publisher_title] if publisher_title.present?
  end

  def ready?
    state == 'ready'
  end
end
