class ChangeStructureThinger < ActiveRecord::Migration
  def self.up
    rename_table(:structure_thingers, :structures)
  end

  def self.down
  end
end
