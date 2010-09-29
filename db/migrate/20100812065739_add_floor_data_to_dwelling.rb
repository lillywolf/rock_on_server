class AddFloorDataToDwelling < ActiveRecord::Migration
  def self.up
    add_column :dwellings, :floor_type, :string
  end

  def self.down
    remove_column :dwellings, :floor_type
  end
end
