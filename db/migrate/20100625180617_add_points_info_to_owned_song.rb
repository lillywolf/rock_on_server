class AddPointsInfoToOwnedSong < ActiveRecord::Migration
  def self.up
    add_column :owned_songs, :points_when_acquired, :int
  end

  def self.down
    remove_column :owned_songs, :points_when_acquired
  end
end
