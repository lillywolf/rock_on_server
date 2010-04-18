class RemoveUserIdFromDwellings < ActiveRecord::Migration
  def self.up
    remove_column :dwellings, :user_id
  end

  def self.down
    add_column :dwellings, :user_id, :int
  end
end
