class AddUnlocksAtToDwelling < ActiveRecord::Migration
  def self.up
    add_column :dwellings, :unlocks_at, :int
  end

  def self.down
    remove_column :dwellings, :unlocks_at, :int
  end
end
