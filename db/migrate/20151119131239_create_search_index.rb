class CreateSearchIndex < ActiveRecord::Migration
  def up
    execute <<-SQL
      ALTER TABLE guides ADD COLUMN tsv tsvector;

      CREATE FUNCTION editions_generate_tsvector() RETURNS TRIGGER AS $$
        BEGIN
          UPDATE guides SET tsv =
              setweight(to_tsvector('pg_catalog.english', coalesce(guides.slug,'')), 'A') ||
              setweight(to_tsvector('pg_catalog.english', coalesce(new.title,'')), 'B')
            WHERE guides.id = new.guide_id
            ;
          return new;
        END
      $$ LANGUAGE plpgsql;

      CREATE TRIGGER tsvector_editions_upsert_trigger AFTER INSERT OR UPDATE
        ON editions
        FOR EACH ROW EXECUTE PROCEDURE editions_generate_tsvector();

      UPDATE guides SET tsv =
        setweight(to_tsvector('pg_catalog.english', coalesce(guides.slug, '')), 'A') ||
        setweight(to_tsvector('pg_catalog.english', coalesce(e.title,'')), 'B')
        FROM (SELECT * FROM editions ORDER BY created_at DESC) e
        WHERE e.guide_id = guides.id
      ;

      CREATE INDEX guides_tsv_idx ON guides USING gin(tsv);
    SQL
  end

  def down
    execute "DROP TRIGGER tsvector_editions_upsert_trigger ON editions"
    execute "DROP INDEX guides_tsv_idx"
    execute "DROP FUNCTION editions_generate_tsvector()"
    remove_column :guides, :tsv
  end
end
