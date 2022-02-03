/**
 * This file contains custom functions which can't be represented in db/schema.rb
 * The database schema is held in db/schema.rb – this file just supplements it.
 * See Rakefile for how this file gets imported.
 */

CREATE FUNCTION editions_generate_tsvector() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
          UPDATE guides SET tsv =
              setweight(to_tsvector('pg_catalog.english', coalesce(guides.slug,'')), 'A') ||
              setweight(to_tsvector('pg_catalog.english', coalesce(new.title,'')), 'B')
            WHERE guides.id = new.guide_id
            ;
          return new;
        END
      $$;

CREATE TRIGGER tsvector_editions_upsert_trigger AFTER INSERT OR UPDATE ON editions FOR EACH ROW EXECUTE PROCEDURE editions_generate_tsvector();
