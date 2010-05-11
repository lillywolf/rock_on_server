class CreateBooths < ActiveRecord::Migration
  def self.up
    create_table :booths do |t|
      t.int :structure_id
      t.int :inventory_capacity
      t.int :item_price

      t.timestamps
    end
  end

  def self.down
    drop_table :booths
  end
end
