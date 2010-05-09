class ChangeFancountUpdateAtForOwnedStructures < ActiveRecord::Migration
  def self.up
    add_column :owned_structures, :inventory_updated_at, :datetime        
  end

  def self.down
    remove_column :owned_structures, :inventory_updated_at, :datetime            
  end
end
