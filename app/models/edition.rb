class Edition < ActiveRecord::Base
  acts_as_commentable

  belongs_to :guide, touch: true
  belongs_to :user

  has_many :approvals

  belongs_to :content_owner

  scope :draft, -> { where(state: 'draft') }
  scope :published, -> { where(state: 'published') }
  scope :review_requested, -> { where(state: 'review_requested') }

  validates_presence_of [:state, :phase, :description, :title, :update_type, :body, :content_owner, :user]
  validates_inclusion_of :state, in: %w(draft published review_requested approved)
  validates :change_note, presence: true, if: :major?
  validate :published_cant_change

  %w{minor major}.each do |s|
    define_method "#{s}?" do
      update_type == s
    end
  end

  [:insert, :update].each do |action|
    trigger.before(action) do
      <<-SQL
          NEW.tsv :=
            setweight(to_tsvector('pg_catalog.english', coalesce(NEW.title,'')), 'A') ||
            setweight(to_tsvector('pg_catalog.english', coalesce(NEW.body,'')), 'B')
          ;
      SQL
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

  def approved?
    state == 'approved'
  end

  def can_request_review?
    return false if !persisted?
    return false if review_requested?
    return false if published?
    return false if approved?
    true
  end

  def can_be_approved?
    persisted? && review_requested?
  end

  def can_be_published?
    return false if published?
    return false if !latest_edition?
    approved?
  end

  def latest_edition?
    self == guide.latest_edition
  end

  def content_owner_title
    content_owner.try(:title)
  end

  def previously_published_edition
    guide.editions.published.where("id < ?", id).order(id: :desc).first
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

  def self.tsearch_query(search_terms)
    words = sanitize(search_terms.scan(/\w+/) * "|")
    Edition.from("editions, to_tsquery('pg_catalog.english', #{words}) as q")
      .where("tsv @@ q").order("ts_rank_cd(tsv, q) DESC")
  end

  def self.search search_terms
    select([:title, :body]).tsearch_query(search_terms)
  end

private

  def published_cant_change
    if state_was == 'published' && changes.except('updated_at').present?
      errors.add(:base, "can not be changed after it's been published. Perhaps someone has published it whilst you were editing it.")
    end
  end

  def assign_publisher_href
    self.publisher_href = PUBLISHERS[publisher_title] if publisher_title.present?
  end
end
