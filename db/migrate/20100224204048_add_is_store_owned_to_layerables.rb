class AddIsStoreOwnedToLayerables < ActiveRecord::Migration
  def self.up
    add_column :layerables, :is_store_owned, :boolean
  end

  def self.down
    remove_column :layerables, :is_store_owned
  end
end
