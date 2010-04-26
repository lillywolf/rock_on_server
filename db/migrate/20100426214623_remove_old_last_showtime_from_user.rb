class RemoveOldLastShowtimeFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :old_last_showtime       
  end

  def self.down
  end
end
