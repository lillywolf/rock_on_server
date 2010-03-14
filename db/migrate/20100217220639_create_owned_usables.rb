class CreateOwnedUsables < ActiveRecord::Migration
  def self.up
    create_table :owned_usables do |t|
      t.int :usable_id
      t.int :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :owned_usables
  end
end
