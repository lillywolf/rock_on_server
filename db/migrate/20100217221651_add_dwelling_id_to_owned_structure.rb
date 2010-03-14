class AddDwellingIdToOwnedStructure < ActiveRecord::Migration
  def self.up
    add_column :owned_structures, :dwelling_id, :int
  end

  def self.down
    remove_column :owned_structures, :dwelling_id
  end
end
