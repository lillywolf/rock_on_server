class AddStoreIdToStoreOwnedThinger < ActiveRecord::Migration
  def self.up
    add_column :store_owned_thingers, :store_id, :int
  end

  def self.down
    remove_column :store_owned_thingers, :store_id
  end
end
