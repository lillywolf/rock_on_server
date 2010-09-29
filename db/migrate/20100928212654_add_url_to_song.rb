class AddUrlToSong < ActiveRecord::Migration
  def self.up
    add_column :songs, :url, :string
  end

  def self.down
    remove_column :songs, :url
  end
end
