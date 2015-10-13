class Guide < ActiveRecord::Base
  has_many :editions
  has_one :published_edition, -> { published }, class_name: "GuideEdition"
  has_one :draft_edition, -> { draft }, class_name: "GuideEdition"
end
