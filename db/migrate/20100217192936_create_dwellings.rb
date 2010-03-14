class CreateDwellings < ActiveRecord::Migration
  def self.up
    create_table :dwellings do |t|
      t.string :name
      t.string :symbol_name
      t.string :swf_url

      t.timestamps
    end
  end

  def self.down
    drop_table :dwellings
  end
end
