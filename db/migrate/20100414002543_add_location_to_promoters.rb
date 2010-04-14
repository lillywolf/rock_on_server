class AddLocationToPromoters < ActiveRecord::Migration
  def self.up
    add_column :promoters, :x, :int
    add_column :promoters, :y, :int
    add_column :promoters, :z, :int
  end

  def self.down
    remove_column :promoters, :z
    remove_column :promoters, :y
    remove_column :promoters, :x
  end
end
