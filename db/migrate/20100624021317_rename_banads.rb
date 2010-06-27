class RenameBanads < ActiveRecord::Migration
  def self.up
    rename_table :bands, :creature_groups
  end

  def self.down
    rename_table :creature_groups, :bands
  end
end
