require 'gds_api/rummager'

class SlugMigration < ActiveRecord::Base
  belongs_to :guide

  validates :slug, uniqueness: true
  validate(
    :guide_must_be_nil_or_published,
    :guide_cant_be_empty_when_migrating,
    :is_not_already_completed,
  )

  before_validation on: :create do |object|
    object.content_id = SecureRandom.uuid
  end

  def has_search_document?
    @search_client ||= GdsApi::Rummager.new(Plek.current.find('rummager'), disable_cache: true)
    begin
      @search_client.get_content!(slug)
    rescue GdsApi::HTTPNotFound => e
      false
    end
  end

  def delete_search_document!
    @search_client ||= GdsApi::Rummager.new(Plek.current.find('rummager'), disable_cache: true)
    @search_client.delete_content!(slug)
  end

  private

    def guide_must_be_nil_or_published
      if guide && !guide.editions.where(state: "published").any?
        errors.add(:guide, "must have a published edition")
      end
    end

    def guide_cant_be_empty_when_migrating
      if completed? && guide.nil?
        errors.add(:guide, "must not be blank")
      end
    end

    def is_not_already_completed
      if completed_was
        errors.add(:base, "is completed and can not be modified")
      end
    end
end
