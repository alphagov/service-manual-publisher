# This migration was auto-generated via `rake db:generate_trigger_migration'.
# While you can edit this file, any changes you make to the definitions here
# will be undone by the next auto-generated trigger migration.

class CreateTriggersEditionsInsertOrEditionsUpdate < ActiveRecord::Migration
  def up
    create_trigger("editions_before_insert_row_tr", :generated => true, :compatibility => 1).
        on("editions").
        before(:insert) do
      <<-SQL_ACTIONS
          NEW.tsv :=
            setweight(to_tsvector('pg_catalog.english', coalesce(NEW.title,'')), 'A') ||
            setweight(to_tsvector('pg_catalog.english', coalesce(NEW.body,'')), 'B')
          ;
      SQL_ACTIONS
    end

    create_trigger("editions_before_update_row_tr", :generated => true, :compatibility => 1).
        on("editions").
        before(:update) do
      <<-SQL_ACTIONS
          NEW.tsv :=
            setweight(to_tsvector('pg_catalog.english', coalesce(NEW.title,'')), 'A') ||
            setweight(to_tsvector('pg_catalog.english', coalesce(NEW.body,'')), 'B')
          ;
      SQL_ACTIONS
    end
  end

  def down
    drop_trigger("editions_before_insert_row_tr", "editions", :generated => true)

    drop_trigger("editions_before_update_row_tr", "editions", :generated => true)
  end
end
