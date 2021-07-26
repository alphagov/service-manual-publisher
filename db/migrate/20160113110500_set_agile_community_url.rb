class SetAgileCommunityUrl < ActiveRecord::Migration[5.2]
  def up
    execute "UPDATE content_owners SET href = '/service-manual/agile-delivery-community' WHERE title = 'Agile Community'"
  end

  def down; end
end
