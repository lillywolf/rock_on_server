class RedoAddUsableIdToOwnedUsables < ActiveRecord::Migration
  def self.up
	remove_column :usables, :usable_id
  end

  def self.down
	add_column :usables, :usable_id, :int
  end
end
