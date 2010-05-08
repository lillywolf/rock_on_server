class OwnedStructure < ActiveRecord::Base
  belongs_to :user
  belongs_to :structure
  belongs_to :dwelling
  
  def validate_usage_complete(array)
    @time_elapsed = get_time_elapsed(self.created_at)
    structure = Structure.find(self.structure_id)    
    estimated_time = structure.capacity * structure.collection_time
    if @time_elapsed - estimated_time > -30
      hash = Hash.new
      hash["instance"] = self
      hash["already_loaded"] = true
      hash["model"] = "owned_structure"
      hash["method"] = "validate_usage_complete"
      array.push hash
      self.destroy  
      return true    
    else
      return false
    end    
  end  
  
  def update_inventory_count(owned_dwelling)
    structure = Structure.find(self.structure_id)
    if structure.structure_type == "Booth"
      time_since_last_fancount = get_time_elapsed(owned_dwelling.fancount_updated_at)
      estimated_purchases = (time_since_last_fancount / structure.collection_time) * owned_dwelling.fancount
      if self.inventory_count - estimated_purchases < 0
        self.inventory_count = 0
      else  
        self.inventory_count -= estimated_purchases
      end  
    end
    self.save    
  end  
  
  def get_time_elapsed(time_since)
    time = Time.new
    time_elapsed = time - time_since
    time_elapsed
  end  
  
end
