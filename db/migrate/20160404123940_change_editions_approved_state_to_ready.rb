class ChangeEditionsApprovedStateToReady < ActiveRecord::Migration
  def up
    execute "UPDATE editions SET state = 'ready' WHERE state = 'approved';"
  end

  def down
    execute "UPDATE editions SET state = 'approved' WHERE state = 'ready';"
  end
end
