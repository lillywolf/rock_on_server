class ChangeLastFedToLastNurture < ActiveRecord::Migration
  def self.up
    rename_column :creatures, :last_fed, :last_nurture
  end

  def self.down
    rename_column :creatures, :last_nurture, :last_fed
  end
end
