class CreateCreatures < ActiveRecord::Migration
  def self.up
    create_table :creatures do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :creatures
  end
end
