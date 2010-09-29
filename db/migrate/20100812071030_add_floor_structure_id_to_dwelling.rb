class AddFloorStructureIdToDwelling < ActiveRecord::Migration
  def self.up
    add_column :dwellings, :floor_structure_id, :int    
  end

  def self.down
    remove_column :dwellings, :floor_structure_id
  end
end
