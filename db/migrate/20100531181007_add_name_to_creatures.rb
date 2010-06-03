class AddNameToCreatures < ActiveRecord::Migration
  def self.up
    add_column :creatures, :name, :string
  end

  def self.down
    remove_column :creatures, :name
  end
end
