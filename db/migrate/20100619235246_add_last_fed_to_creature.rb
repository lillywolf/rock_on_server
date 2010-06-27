class AddLastFedToCreature < ActiveRecord::Migration
  def self.up
    add_column :creatures, :last_fed, :datetime
  end

  def self.down
    remove_column :creatures, :last_fed
  end
end
