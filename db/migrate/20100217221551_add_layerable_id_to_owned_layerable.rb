class AddLayerableIdToOwnedLayerable < ActiveRecord::Migration
  def self.up
    add_column :owned_layerables, :layerable_id, :int
  end

  def self.down
    remove_column :owned_layerables, :layerable_id
  end
end
