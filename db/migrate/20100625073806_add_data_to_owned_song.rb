class AddDataToOwnedSong < ActiveRecord::Migration
  def self.up
    add_column :owned_songs, :user_id, :int
    add_column :owned_songs, :band_id, :int
    add_column :owned_songs, :song_id, :int
  end

  def self.down
    remove_column :owned_songs, :user_id
    remove_column :owned_songs, :band_id
    remove_column :owned_songs, :song_id
  end
end
