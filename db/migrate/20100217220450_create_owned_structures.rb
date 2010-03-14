class CreateOwnedStructures < ActiveRecord::Migration
  def self.up
    create_table :owned_structures do |t|
      t.int :structure_id
      t.int :user_id
      t.int :dwelling_id
      t.float :x
      t.float :y
      t.float :z
      t.boolean :in_use

      t.timestamps
    end
  end

  def self.down
    drop_table :owned_structures
  end
end
