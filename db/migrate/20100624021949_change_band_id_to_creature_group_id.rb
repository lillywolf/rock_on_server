class ChangeBandIdToCreatureGroupId < ActiveRecord::Migration
  def self.up
    rename_column :creatures, :band_id, :creature_group_id
  end

  def self.down
    rename_column :creatures, :creature_group_id, :band_id
  end
end
