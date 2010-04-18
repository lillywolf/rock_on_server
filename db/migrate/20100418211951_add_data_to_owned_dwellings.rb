class AddDataToOwnedDwellings < ActiveRecord::Migration
  def self.up
    add_column :owned_dwellings, :current_city, :string
    add_column :owned_dwellings, :fancount, :int
    add_column :owned_dwellings, :last_showtime, :datetime
  end

  def self.down
    remove_column :owned_dwellings, :last_showtime
    remove_column :owned_dwellings, :fancount
    remove_column :owned_dwellings, :current_city
  end
end
