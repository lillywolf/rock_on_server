class CreateUsableThingers < ActiveRecord::Migration
  def self.up
    create_table :usable_thingers do |t|
      t.string :name
      t.string :swf_url
      t.string :symbol_name
      t.string :usable_type

      t.timestamps
    end
  end

  def self.down
    drop_table :usable_thingers
  end
end
