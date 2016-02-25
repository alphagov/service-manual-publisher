require 'gds_api/rummager'

class SlugMigration < ActiveRecord::Base
  validates :slug, uniqueness: true
  validates :redirect_to, presence: true
  validate :is_not_already_completed

  before_save do |object|
    object.content_id = SecureRandom.uuid
  end

  def has_search_document?
    @search_client ||= GdsApi::Rummager.new(Plek.current.find('rummager'), disable_cache: true)
    begin
      @search_client.get_content!(slug)
    rescue GdsApi::HTTPErrorResponse => e
      false
    end
  end

  def delete_search_document!
    @search_client ||= GdsApi::Rummager.new(Plek.current.find('rummager'), disable_cache: true)
    @search_client.delete_content!(slug)
  end

  private

    def is_not_already_completed
      if completed_was
        errors.add(:base, "is completed and can not be modified")
      end
    end
end
