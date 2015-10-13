class Edition < ActiveRecord::Base
  belongs_to :guide
  scope :draft, -> { where(state: 'draft') }
  scope :published, -> { where(state: 'published') }

  validates_presence_of [:state, :phase, :description, :title, :update_type, :body, :publisher_title]

  def draft?
    state == 'draft'
  end

  def published?
    state == 'published'
  end
end
