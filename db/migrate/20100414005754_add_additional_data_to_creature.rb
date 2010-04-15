class AddAdditionalDataToCreature < ActiveRecord::Migration
  def self.up
    add_column :creatures, :additional_info, :string
  end

  def self.down
    remove_column :creatures, :additional_info
  end
end
