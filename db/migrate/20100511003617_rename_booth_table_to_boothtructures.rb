class RenameBoothTableToBoothtructures < ActiveRecord::Migration
  def self.up
    rename_table :booths, :booth_structures
  end

  def self.down
    rename_table :booth_structures, :booths
  end
end
