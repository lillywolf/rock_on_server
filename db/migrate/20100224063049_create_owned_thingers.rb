class CreateOwnedThingers < ActiveRecord::Migration
  def self.up
    create_table :owned_thingers do |t|
      t.boolean :in_use

      t.timestamps
    end
  end

  def self.down
    drop_table :owned_thingers
  end
end
