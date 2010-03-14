class AddIsStoreOwnedToThingers < ActiveRecord::Migration
  def self.up
    add_column :thingers, :is_store_owned, :boolean
  end

  def self.down
    remove_column :thingers, :is_store_owned
  end
end
