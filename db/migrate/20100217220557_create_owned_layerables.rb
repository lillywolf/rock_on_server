class CreateOwnedLayerables < ActiveRecord::Migration
  def self.up
    create_table :owned_layerables do |t|
      t.int :layerable_id
      t.int :user_id
      t.int :r
      t.int :g
      t.int :b
      t.boolean :in_use

      t.timestamps
    end
  end

  def self.down
    drop_table :owned_layerables
  end
end
