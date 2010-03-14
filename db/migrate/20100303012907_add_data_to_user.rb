class AddDataToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :xp, :int
    add_column :users, :credits, :int
    add_column :users, :premium_credits, :int
  end

  def self.down
    remove_column :users, :premium_credits
    remove_column :users, :credits
    remove_column :users, :xp
  end
end
