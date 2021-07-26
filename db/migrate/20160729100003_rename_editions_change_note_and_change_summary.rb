class RenameEditionsChangeNoteAndChangeSummary < ActiveRecord::Migration[5.2]
  def change
    rename_column :editions, :change_note, :reason_for_change
    rename_column :editions, :change_summary, :change_note
  end
end
