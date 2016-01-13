class SetAgileCommunityUrl < ActiveRecord::Migration
  def change
    execute "UPDATE content_owners SET href = '/service-manual/agile-delivery-community' WHERE title = 'Agile Community'"
  end
end
