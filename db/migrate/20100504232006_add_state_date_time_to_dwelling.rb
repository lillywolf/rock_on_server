class AddStateDateTimeToDwelling < ActiveRecord::Migration
  def self.up
    add_column :owned_dwellings, :state_updated_at, :datetime            
  end

  def self.down
    remove_column :owned_dwellings, :state_updated_at
  end
end
