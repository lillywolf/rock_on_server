class ChangeLevelForUser < ActiveRecord::Migration
  def self.up
    rename_column :users, :level, :level_id    
  end

  def self.down
    rename_column :users, :level_id, :level        
  end
end
