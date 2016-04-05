class PopulateEditionVersions < ActiveRecord::Migration
  class FakeGuide < ActiveRecord::Base
    self.table_name = 'guides'
    has_many :editions, class_name: 'FakeEdition', foreign_key: 'guide_id'
  end

  class FakeEdition < ActiveRecord::Base
    self.table_name = 'editions'
  end

  def change
    FakeGuide.all.each do |guide|
      version = 1
      guide.editions.order(created_at: :asc).each do |edition|
        edition.update_columns(version: version)
        version += 1
      end
    end
  end
end
