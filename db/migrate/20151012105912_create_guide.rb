class CreateGuide < ActiveRecord::Migration
  def change
    create_table :guides do |t|
      t.string :slug
      t.string :title
    end
  end
end
