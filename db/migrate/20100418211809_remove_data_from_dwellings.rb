class RemoveDataFromDwellings < ActiveRecord::Migration
  def self.up
    remove_column :dwellings, :last_showtime
    remove_column :dwellings, :current_fancount
    remove_column :dwellings, :current_city
  end

  def self.down
    add_column :dwellings, :current_city, :string
    add_column :dwellings, :current_fancount, :int
    add_column :dwellings, :last_showtime, :datetime
  end
end
