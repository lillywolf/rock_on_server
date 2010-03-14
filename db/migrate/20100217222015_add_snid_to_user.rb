class AddSnidToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :snid, :int
  end

  def self.down
    remove_column :users, :snid
  end
end
