class AddDimensionsToDwelling < ActiveRecord::Migration
  def self.up
    add_column :dwellings, :dimension, :int
    add_column :dwellings, :sidewalk_dimension, :int
  end

  def self.down
    remove_column :dwellings, :dimension
    remove_column :dwellings, :sidewalk_dimension
  end
end
