class AddDataToOwnedThinger < ActiveRecord::Migration
  def self.up
    add_column :owned_thingers, :user_id, :int
    add_column :owned_thingers, :thinger_id, :int
    add_column :owned_thingers, :x, :float
    add_column :owned_thingers, :y, :float
    add_column :owned_thingers, :z, :float
  end

  def self.down
    remove_column :owned_thingers, :z
    remove_column :owned_thingers, :y
    remove_column :owned_thingers, :x
    remove_column :owned_thingers, :thinger_id
    remove_column :owned_thingers, :user_id
  end
end
