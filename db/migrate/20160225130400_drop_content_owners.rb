class DropContentOwners < ActiveRecord::Migration
  class FakeContentOwner < ActiveRecord::Base
    self.table_name = "content_owners"
  end
  class FakeGuide < ActiveRecord::Base
    self.table_name = "guides"

    has_many :editions, class_name: "FakeEdition", foreign_key: "guide_id"
  end
  class FakeEdition < ActiveRecord::Base
    self.table_name = "editions"
  end

  def up
    # Create a temporary column to store the relation to the relevant guide
    add_column :editions, :new_content_owner_id, :integer

    design_community_guide = FakeGuide.joins(:editions)
      .where("editions.title = ?", "Design Community")
      .first
    agile_community_guide  = FakeGuide.joins(:editions)
      .where("editions.title = ?", "Agile Community")
      .first

    design_content_owner = FakeContentOwner.find_by_title("Design Community")
    agile_content_owner = FakeContentOwner.find_by_title("Agile Community")


    if design_community_guide && design_content_owner
      FakeEdition.where(content_owner_id: design_content_owner.id)
        .update_all(new_content_owner_id: design_community_guide.id)
    end

    if agile_community_guide && agile_content_owner
      FakeEdition.where(content_owner_id: agile_content_owner.id)
        .update_all(new_content_owner_id: agile_community_guide.id)
    end


    [design_community_guide, agile_community_guide].each do |community_guide|
      if community_guide.present?
        # Mark the community guides with the community flag
        community_guide.update_attribute(:type, "GuideCommunity")

        # Remove the content_owner_ids from all community guides as they do not have owners
        community_guide.editions.update_all(new_content_owner_id: nil)
      end
    end

    # Remove the old content_owner_id along with any relations we didn't know about
    remove_column :editions, :content_owner_id
    # Rename the temporary column to the same name as the old one
    rename_column :editions, :new_content_owner_id, :content_owner_id

    drop_table :content_owners
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
