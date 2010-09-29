class AddReferenceIdToCreature < ActiveRecord::Migration
  def self.up
    add_column :creatures, :reference_id, :int
  end

  def self.down
    remove_column :creatures, :reference_id
  end
end
