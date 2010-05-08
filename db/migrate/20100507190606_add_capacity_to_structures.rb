class AddCapacityToStructures < ActiveRecord::Migration
  def self.up
    add_column :structures, :capacity, :int    
  end

  def self.down
    remove_column :structures, :capacity, :int        
  end
end
