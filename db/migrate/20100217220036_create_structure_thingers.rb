class CreateStructureThingers < ActiveRecord::Migration
  def self.up
    create_table :structure_thingers do |t|
      t.string :name
      t.string :swf_url
      t.string :symbol_name
      t.string :structure_type

      t.timestamps
    end
  end

  def self.down
    drop_table :structure_thingers
  end
end
