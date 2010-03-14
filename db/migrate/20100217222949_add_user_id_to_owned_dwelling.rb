class AddUserIdToOwnedDwelling < ActiveRecord::Migration
  def self.up
    add_column :owned_dwellings, :user_id, :int
    add_column :owned_dwellings, :dwelling_id, :int
  end

  def self.down
    remove_column :owned_dwellings, :dwelling_id
    remove_column :owned_dwellings, :user_id
  end
end
