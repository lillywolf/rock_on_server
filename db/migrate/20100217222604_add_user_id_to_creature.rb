class AddUserIdToCreature < ActiveRecord::Migration
  def self.up
    add_column :creatures, :user_id, :int
  end

  def self.down
    remove_column :creatures, :user_id
  end
end
