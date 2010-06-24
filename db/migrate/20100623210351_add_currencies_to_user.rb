class AddCurrenciesToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :fan_hearts, :int
    add_column :users, :music_credits, :int
  end

  def self.down
    remove_column :users, :fan_hearts
    remove_column :users, :music_credits
  end
end
