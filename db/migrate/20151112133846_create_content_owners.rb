class CreateContentOwners < ActiveRecord::Migration[5.2]
  def change
    create_table :content_owners do |t|
      t.string :title, null: false
      t.string :href, null: false
    end

    execute "INSERT INTO content_owners (title, href) VALUES ('Design Community', 'http://sm-11.herokuapp.com/designing-services/design-community/')"
    execute "INSERT INTO content_owners (title, href) VALUES ('Agile Community', 'http://sm-11.herokuapp.com/agile-delivery/agile-community')"

    remove_column :editions, :publisher_title, :content_owner_title
    remove_column :editions, :publisher_href, :content_owner_href

    add_column :editions, :content_owner_id, :integer, null: true
    execute "UPDATE editions SET content_owner_id = (SELECT id FROM content_owners LIMIT 1) WHERE content_owner_id IS NULL"
    change_column_null :editions, :content_owner_id, false
  end
end
