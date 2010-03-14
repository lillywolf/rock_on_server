class CreateThingers < ActiveRecord::Migration
  def self.up
    create_table :thingers do |t|
      t.string :name
      t.string :thinger_type
      t.string :swf_url
      t.string :symbol_name
      t.int :unlockable_at

      t.timestamps
    end
  end

  def self.down
    drop_table :thingers
  end
end
