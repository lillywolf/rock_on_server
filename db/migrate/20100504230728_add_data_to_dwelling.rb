class AddDataToDwelling < ActiveRecord::Migration
  def self.up
    add_column :owned_dwellings, :last_state, :string        
  end

  def self.down
    remove_column :owned_dwellings, :last_state
  end
end
