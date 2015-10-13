class Edition < ActiveRecord::Base
  belongs_to :guide
  scope :draft, -> { where(state: 'draft') }
  scope :published, -> { where(state: 'published') }

  validates :state, presence: true
  validates :title, presence: true

  def draft?
    state == 'draft'
  end

  def published?
    state == 'published'
  end
end
