class CreateGuide < ActiveRecord::Migration[5.2]
  def change
    create_table :guides do |t|
      t.string :slug
      t.string :title
    end
  end
end
