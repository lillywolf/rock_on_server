class ChangeDwellingIdToOwnedDwellingIdForOwnedStructure < ActiveRecord::Migration
  def self.up
    rename_column :owned_structures, :dwelling_id, :owned_dwelling_id            
  end

  def self.down
    rename_column :owned_structures, :owned_dwelling_id, :dwelling_id                
  end
end
