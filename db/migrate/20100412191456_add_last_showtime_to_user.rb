class AddLastShowtimeToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :last_showtime, :int
  end

  def self.down
    remove_column :users, :last_showtime
  end
end
