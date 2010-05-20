class AddDataToBooths < ActiveRecord::Migration
  def self.up
    add_column :booths, :structure_id, :int
    add_column :booths, :inventory_capacity, :int
    add_column :booths, :item_price, :int
  end

  def self.down
    remove_column :booths, :structure_id
    remove_column :booths, :inventory_capcity
    remove_column :booths, :item_price
  end
end
