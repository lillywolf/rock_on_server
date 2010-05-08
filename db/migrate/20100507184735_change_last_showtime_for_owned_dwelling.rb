class ChangeLastShowtimeForOwnedDwelling < ActiveRecord::Migration
  def self.up
    rename_column :owned_dwellings, :last_showtime, :fancount_updated_at    
  end

  def self.down
    rename_column :users, :fancount_updated_at, :last_showtime        
  end
end
