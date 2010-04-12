class ChangeShowtimeForUser < ActiveRecord::Migration
  def self.up
    change_column :users, :last_showtime, :datetime    
  end

  def self.down
  end
end
