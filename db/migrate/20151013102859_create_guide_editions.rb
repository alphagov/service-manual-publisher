class CreateGuideEditions < ActiveRecord::Migration
  def change
    create_table :guide_editions do |t|
      t.references :guide
      t.references :user

      t.text :title
      t.text :description
      t.text :body

      t.string :update_type
      t.string :phase

      t.text :publisher_title
      t.text :publisher_href
      t.text :related_discussion_href
      t.text :related_discussion_title

      t.timestamps null: false
    end
  end
end
