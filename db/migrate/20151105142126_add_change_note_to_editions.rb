class AddChangeNoteToEditions < ActiveRecord::Migration[5.2]
  def change
    add_column :editions, :change_note, :text
  end
end
