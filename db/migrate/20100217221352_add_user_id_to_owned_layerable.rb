class AddUserIdToOwnedLayerable < ActiveRecord::Migration
  def self.up
    add_column :owned_layerables, :user_id, :int
  end

  def self.down
    remove_column :owned_layerables, :user_id
  end
end
