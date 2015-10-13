class GuideEdition < ActiveRecord::Base
  belongs_to :guide
  scope :draft, -> { where(state: 'draft') }
  scope :published, -> { where(state: 'published') }
end
