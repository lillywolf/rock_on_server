class CreateLayerableThingers < ActiveRecord::Migration
  def self.up
    create_table :layerable_thingers do |t|
      t.string :name
      t.string :swf_url
      t.string :symbol_name
      t.string :layer_name
      t.boolean :is_default
      t.boolean :editable_color

      t.timestamps
    end
  end

  def self.down
    drop_table :layerable_thingers
  end
end
