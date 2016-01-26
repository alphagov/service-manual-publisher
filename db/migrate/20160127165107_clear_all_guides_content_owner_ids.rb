class ClearAllGuidesContentOwnerIds < ActiveRecord::Migration
  def change
    execute 'UPDATE editions SET content_owner_id = NULL;'
  end
end
