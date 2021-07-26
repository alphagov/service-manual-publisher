class RenameUnpublishesToRedirects < ActiveRecord::Migration[5.2]
  def change
    rename_table :unpublishes, :redirects
  end
end
