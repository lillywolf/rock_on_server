class OwnedStructure < ActiveRecord::Base
  belongs_to :user
  belongs_to :structure
  belongs_to :dwelling
  
  INVENTORY_ERROR_MARGIN = 10
  STATION_TIME_BUFFER = -30
  SALE_XP_MULTIPLIER = 2
  
  def validate_usage_complete(array)
    @time_elapsed = get_time_elapsed(self.created_at)
    structure = Structure.find(self.structure_id)    
    estimated_time = structure.capacity * structure.collection_time
    if @time_elapsed - estimated_time > STATION_TIME_BUFFER
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
      num_groupies = 0
      user = User.find(self.user_id)
      Creature.find_each(:conditions => ["user_id = ?", user.id]) do |creature|
        if creature.creature_type == "Groupie"
          num_groupies = num_groupies + 1
        end  
      end  
      time_since_last_update = get_time_elapsed(self.inventory_updated_at)
      estimated_purchases = (time_since_last_update / structure.collection_time) * (owned_dwelling.fancount + num_groupies)
      if self.inventory_count - estimated_purchases < 0
        self.inventory_count = 0
      else  
        self.inventory_count -= estimated_purchases
      end
      self.inventory_updated_at = Time.new  
    end
    self.save    
  end 
  
  def validate_inventory_count_zero
    if self.inventory_count < INVENTORY_ERROR_MARGIN
      self.inventory_count = 0
    end    
  end
  
  def save_new_placement(x, y, z)
    self.x = x.to_f
    self.y = y.to_f
    self.z = z.to_f
    self.save
  end 
  
  def save_rotation(rotation)
    self.rotation = rotation.to_i
    self.save
  end     
  
  def do_type_specific_updates
    structure = Structure.find(self.structure_id)
    if structure.structure_type == "Booth"
      owned_dwelling = OwnedDwelling.find(self.owned_dwelling_id)
      update_inventory_count(owned_dwelling)
    elsif structure.structure_type == "ListeningStation"
      
    end        
  end
  
  def do_type_specific_creation
    structure = Structure.find(self.structure_id)
    if structure.structure_type == "Booth"
      BoothStructure.find_each(:conditions => ["structure_id = ?", structure.id]) do |booth_structure|
        self.inventory_count = booth_structure.inventory_capacity
      end  
      self.inventory_updated_at = Time.new
    elsif structure.structure_type == "ListeningStation"
      
    end    
  end  
  
  def add_hash(array, method, already_loaded)
    hash = Hash.new
    hash["instance"] = self
    hash["already_loaded"] = already_loaded
    hash["model"] = "owned_structure"
    hash["method"] = method
    array.push hash   
  end     
  
  def get_time_elapsed(time_since)
    time = Time.new
    time_elapsed = time - time_since
    time_elapsed
  end  
  
end
