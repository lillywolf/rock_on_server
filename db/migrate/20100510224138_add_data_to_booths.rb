class AddDataToBooths < ActiveRecord::Migration
  def self.up
    add_column :booth_structures, :structure_id, :int
    add_column :booth_structures, :inventory_capacity, :int
    add_column :booth_structures, :item_price, :int
  end

  def self.down
    remove_column :booth_structures, :structure_id
    remove_column :booth_structures, :inventory_capcity
    remove_column :booth_structures, :item_price
  end
end
