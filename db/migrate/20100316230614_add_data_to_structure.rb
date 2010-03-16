class AddDataToStructure < ActiveRecord::Migration
  def self.up
    add_column :structures, :width, :float
    add_column :structures, :height, :float
    add_column :structures, :depth, :float
  end

  def self.down
    remove_column :structures, :depth
    remove_column :structures, :height
    remove_column :structures, :width
  end
end
