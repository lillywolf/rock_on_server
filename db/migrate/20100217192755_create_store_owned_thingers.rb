class CreateStoreOwnedThingers < ActiveRecord::Migration
  def self.up
    create_table :store_owned_thingers do |t|
      t.int :price
      t.int :premium_price

      t.timestamps
    end
  end

  def self.down
    drop_table :store_owned_thingers
  end
end
