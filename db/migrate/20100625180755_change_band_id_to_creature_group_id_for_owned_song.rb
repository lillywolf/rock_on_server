class ChangeBandIdToCreatureGroupIdForOwnedSong < ActiveRecord::Migration
  def self.up
    rename_column :owned_songs, :band_id, :creature_group_id
  end

  def self.down
    rename_column :owned_songs, :creature_group_id, :band_id
  end
end
