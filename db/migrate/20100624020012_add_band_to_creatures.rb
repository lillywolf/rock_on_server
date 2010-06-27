class AddBandToCreatures < ActiveRecord::Migration
  def self.up
    add_column :creatures, :band_id, :int
  end

  def self.down
    remove_column :creatures, :band_id
  end
end
