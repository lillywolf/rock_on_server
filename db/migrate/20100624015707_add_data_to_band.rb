class AddDataToBand < ActiveRecord::Migration
  def self.up
    add_column :bands, :owned_dwelling_id, :int
    add_column :bands, :user_id, :int
  end

  def self.down
    remove_column :bands, :owned_dwelling_id
    remove_column :bands, :user_id
  end
end
