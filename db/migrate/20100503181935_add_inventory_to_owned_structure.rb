class AddInventoryToOwnedStructure < ActiveRecord::Migration
  def self.up
    add_column :owned_structures, :inventory_count, :int    
  end

  def self.down
    remove_column :owned_structures, :inventory_count        
  end
end
