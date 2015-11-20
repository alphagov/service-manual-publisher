class CreateSearchIndex < ActiveRecord::Migration
  TABLE_NAME = :editions

  def up
    add_column :editions, :tsv, :tsvector
    add_index :editions, :tsv, using: "gin"

    execute <<-SQL
      UPDATE #{TABLE_NAME} SET tsv =
        setweight(to_tsvector('pg_catalog.english', coalesce(title,'')), 'A') ||
        setweight(to_tsvector('pg_catalog.english', coalesce(body,'')), 'B')
      ;
      CREATE INDEX #{TABLE_NAME}_tsv_idx ON #{TABLE_NAME} USING gin(tsv);
    SQL
  end

  def down
    remove_index :editions, :tsv
    remove_column :editions, :tsv
  end
end
