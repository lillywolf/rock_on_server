class ChangeUsableThinger < ActiveRecord::Migration
  def self.up
    rename_table(:usable_thingers, :usables)
  end

  def self.down
  end
end
