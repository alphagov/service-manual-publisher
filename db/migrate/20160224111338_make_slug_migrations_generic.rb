class MakeSlugMigrationsGeneric < ActiveRecord::Migration
  def change
    add_column :slug_migrations, :redirect_to, :string

    execute <<-SQL
      UPDATE slug_migrations
        SET redirect_to = guides.slug
        FROM guides
        WHERE slug_migrations.guide_id IS NOT NULL
        AND slug_migrations.guide_id = guides.id
    SQL
  end
end
