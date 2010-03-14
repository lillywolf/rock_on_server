class AddCreatureIdToOwnedLayerable < ActiveRecord::Migration
  def self.up
    add_column :owned_layerables, :creature_id, :int
  end

  def self.down
    remove_column :owned_layerables, :creature_id
  end
end
