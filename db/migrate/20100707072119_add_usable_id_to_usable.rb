class AddUsableIdToUsable < ActiveRecord::Migration
  def self.up
	add_column :usables, :usable_id, :int
  end

  def self.down
	remove_column :usables, :usable_id
  end
end
