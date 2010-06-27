class CreateOwnedSongs < ActiveRecord::Migration
  def self.up
    create_table :owned_songs do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :owned_songs
  end
end
