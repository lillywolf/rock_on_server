class ChangeUserSnidToBigint < ActiveRecord::Migration
  def self.up
    change_column :users, :snid, :bigint
  end

  def self.down
    change_column :users, :snid, :int
  end
end
