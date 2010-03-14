class AddCreatureTypeToCreature < ActiveRecord::Migration
  def self.up
    add_column :creatures, :creature_type, :string
  end

  def self.down
    remove_column :creatures, :creature_type
  end
end
