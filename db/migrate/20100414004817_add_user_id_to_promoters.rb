class AddUserIdToPromoters < ActiveRecord::Migration
  def self.up
    add_column :promoters, :user_id, :int
  end

  def self.down
    remove_column :promoters, :user_id
  end
end
