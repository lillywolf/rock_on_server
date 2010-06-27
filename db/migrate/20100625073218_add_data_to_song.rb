class AddDataToSong < ActiveRecord::Migration
  def self.up
    add_column :songs, :artist_name, :string
    add_column :songs, :title, :string
    add_column :songs, :genre, :string
    add_column :songs, :points, :int
    add_column :songs, :user_id, :int
  end

  def self.down
    remove_column :songs, :artist_name
    remove_column :songs, :title
    remove_column :songs, :genre
    remove_column :songs, :points
    remove_column :songs, :user_id
  end
end
