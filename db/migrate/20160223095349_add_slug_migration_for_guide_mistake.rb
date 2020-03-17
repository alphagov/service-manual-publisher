class AddSlugMigrationForGuideMistake < ActiveRecord::Migration
  def up
    return say("Skipping slug creation in test environment") if Rails.env.test?

    SLUGS.each do |s|
      execute "INSERT INTO slug_migrations (slug, created_at, updated_at, content_id) VALUES ('#{s}', now(), now(), '#{SecureRandom.uuid}')"
    end
  end

  SLUGS = [
    "/service-manual/service-manual/digital-foundation-day-training",
  ].freeze
end
