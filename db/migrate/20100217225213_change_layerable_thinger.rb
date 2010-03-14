class ChangeLayerableThinger < ActiveRecord::Migration
  def self.up
    rename_table(:layerable_thingers, :layerables)
  end

  def self.down
  end
end
