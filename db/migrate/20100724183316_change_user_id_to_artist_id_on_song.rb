class ChangeUserIdToArtistIdOnSong < ActiveRecord::Migration
  def self.up
    rename_column :songs, :user_id, :artist_id
  end

  def self.down
    rename_column :songs, :artist_id, :user_id
  end
end
