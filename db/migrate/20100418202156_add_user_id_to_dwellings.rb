class AddUserIdToDwellings < ActiveRecord::Migration
  def self.up
    add_column :dwellings, :user_id, :int
  end

  def self.down
    remove_column :dwellings, :user_id
  end
end
