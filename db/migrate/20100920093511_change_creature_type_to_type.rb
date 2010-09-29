class ChangeCreatureTypeToType < ActiveRecord::Migration
  def self.up
    rename_column :creatures, :creature_type, :type
  end

  def self.down
    rename_column :creatures, :type, :creature_type
  end
end
