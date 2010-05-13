class ChangeOrderForLevel < ActiveRecord::Migration
  def self.up
    rename_column :levels, :order, :rank
  end

  def self.down
    rename_column :levels, :rank, :order
  end
end
