class AddFanCollectionTimeToStructure < ActiveRecord::Migration
  def self.up
    add_column :structures, :collection_time, :int    
  end

  def self.down
    remove_column :structures, :collection_time, :int    
  end
end
