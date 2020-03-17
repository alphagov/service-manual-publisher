class SetAgileCommunityUrl < ActiveRecord::Migration
  def up
    execute "UPDATE content_owners SET href = '/service-manual/agile-delivery-community' WHERE title = 'Agile Community'"
  end

  def down; end
end
