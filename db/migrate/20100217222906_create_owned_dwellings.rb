class CreateOwnedDwellings < ActiveRecord::Migration
  def self.up
    create_table :owned_dwellings do |t|
      t.int :user_id
      t.int :dwelling_id

      t.timestamps
    end
  end

  def self.down
    drop_table :owned_dwellings
  end
end
