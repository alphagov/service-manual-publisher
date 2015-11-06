class AddChangeNoteToEditions < ActiveRecord::Migration
  def change
    add_column :editions, :change_note, :text
  end
end
