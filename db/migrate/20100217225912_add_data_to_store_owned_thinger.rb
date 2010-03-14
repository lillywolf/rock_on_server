class AddDataToStoreOwnedThinger < ActiveRecord::Migration
  def self.up
    add_column :store_owned_thingers, :price, :int
    add_column :store_owned_thingers, :premium_price, :int
    add_column :store_owned_thingers, :thinger_type, :string
    add_column :store_owned_thingers, :thinger_id, :int
  end

  def self.down
    remove_column :store_owned_thingers, :thinger_id
    remove_column :store_owned_thingers, :thinger_type
    remove_column :store_owned_thingers, :premium_price
    remove_column :store_owned_thingers, :price
  end
end
