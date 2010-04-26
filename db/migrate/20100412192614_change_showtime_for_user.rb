class ChangeShowtimeForUser < ActiveRecord::Migration
  def self.up
    rename_column :users, :last_showtime, :old_last_showtime
    add_column :users, :last_showtime, :datetime      
  end

  def self.down
    remove_column :users, :last_showtime
    rename_column :users, :old_last_showtime, :last_showtime    
  end
end
