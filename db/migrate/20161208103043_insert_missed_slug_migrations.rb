class InsertMissedSlugMigrations < ActiveRecord::Migration
  def change
    return say("Skipping slug creation in test environment") if Rails.env.test?

    OLD_SLUGS.each do |s|
      execute "INSERT INTO slug_migrations (slug, created_at, updated_at, content_id) VALUES ('#{s}', now(), now(), '#{SecureRandom.uuid}')"
    end
  end

  OLD_SLUGS = [
    "/service-manual/user-centred-design/resources/patterns/question-pages.html",
    "/service-manual/user-centred-design/resources/patterns/question-pages",
    "/service-manual/user-centred-design/resources/patterns/check-your-answers-pages.html",
    "/service-manual/user-centred-design/resources/patterns/check-your-answers-pages"
  ]
end
