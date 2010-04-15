class AddLocationToCreature < ActiveRecord::Migration
  def self.up
    add_column :creatures, :x, :int
    add_column :creatures, :y, :int
    add_column :creatures, :z, :int
  end

  def self.down
    remove_column :creatures, :z
    remove_column :creatures, :y
    remove_column :creatures, :x
  end
end
