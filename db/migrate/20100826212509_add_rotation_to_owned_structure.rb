class AddRotationToOwnedStructure < ActiveRecord::Migration
  def self.up
    add_column :owned_structures, :rotation, :int
  end

  def self.down
    remove_column :owned_structures, :rotation
  end
end
