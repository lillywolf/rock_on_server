class AddDataToDwellings < ActiveRecord::Migration
  def self.up
    add_column :dwellings, :dwelling_type, :string
    add_column :dwellings, :last_showtime, :datetime
    add_column :dwellings, :current_fancount, :int
    add_column :dwellings, :current_city, :string
    add_column :dwellings, :capacity, :int
  end

  def self.down
    remove_column :dwellings, :capacity
    remove_column :dwellings, :current_city
    remove_column :dwellings, :current_fancount
    remove_column :dwellings, :last_showtime
    remove_column :dwellings, :dwelling_type
  end
end
