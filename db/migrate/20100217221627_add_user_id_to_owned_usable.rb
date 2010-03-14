class AddUserIdToOwnedUsable < ActiveRecord::Migration
  def self.up
    add_column :owned_usables, :user_id, :int
    add_column :owned_usables, :usable_id, :int
  end

  def self.down
    remove_column :owned_usables, :usable_id
    remove_column :owned_usables, :user_id
  end
end
