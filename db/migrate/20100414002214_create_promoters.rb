class CreatePromoters < ActiveRecord::Migration
  def self.up
    create_table :promoters do |t|
      t.string :promoter_type
      t.int :x
      t.int :y
      t.int :z

      t.timestamps
    end
  end

  def self.down
    drop_table :promoters
  end
end
