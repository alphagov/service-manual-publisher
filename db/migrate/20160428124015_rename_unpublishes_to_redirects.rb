class RenameUnpublishesToRedirects < ActiveRecord::Migration
  def change
    rename_table :unpublishes, :redirects
  end
end
