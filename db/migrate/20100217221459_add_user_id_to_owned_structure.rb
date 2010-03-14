class AddUserIdToOwnedStructure < ActiveRecord::Migration
  def self.up
    add_column :owned_structures, :user_id, :int
    add_column :owned_structures, :structure_id, :int
  end

  def self.down
    remove_column :owned_structures, :structure_id
    remove_column :owned_structures, :user_id
  end
end
