class AddRgbToOwnedLayerable < ActiveRecord::Migration
  def self.up
    add_column :owned_layerables, :r, :int
    add_column :owned_layerables, :g, :int
    add_column :owned_layerables, :b, :int
  end

  def self.down
    remove_column :owned_layerables, :b
    remove_column :owned_layerables, :g
    remove_column :owned_layerables, :r
  end
end
