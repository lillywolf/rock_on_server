class AddDataToLevels < ActiveRecord::Migration
  def self.up
    add_column :levels, :order, :int
    add_column :levels, :xp_diff, :int
    add_column :levels, :items_unlocked, :text
    add_column :levels, :dwelling_expansion_x, :int
    add_column :levels, :dwelling_expansion_y, :int
    add_column :levels, :dwelling_expansion_z, :int
  end

  def self.down
    remove_column :levels, :dwelling_expansion_z
    remove_column :levels, :dwelling_expansion_y
    remove_column :levels, :dwelling_expansion_x
    remove_column :levels, :items_unlocked
    remove_column :levels, :xp_diff
    remove_column :levels, :order
  end
end
