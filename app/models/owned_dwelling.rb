class OwnedDwelling < ActiveRecord::Base
  belongs_to :user
  belongs_to :dwelling
  has_many :owned_structures
  
  SHOW_TIME = 3600
  ENCORE_TIME = 360
  ENCORE_WAIT_TIME = 1800
  FILL_FRACTION = 0.5
  
  def validate_state_change(time_elapsed_client, show_button_clicked)

    @time_elapsed = get_time_elapsed(self.state_updated_at)
    
    # If state change requested by client-side timer, check it and updated time_elapsed
    
    if (time_elapsed_client)
      time_elapsed_client = time_elapsed_client.to_i      
      if (@time_elapsed - time_elapsed_client).abs < 30
        @time_elapsed = time_elapsed_client
      end
    end  
    
    dwelling = Dwelling.find(self.dwelling_id)
    
    # If statements for state switching    

    if self.last_state == "empty_state"
      if self.fancount > FILL_FRACTION * dwelling.capacity
        self.last_state = "show_wait_state"
        self.state_updated_at = Time.new
      end    
    elsif self.last_state == "show_state"
      if @time_elapsed > SHOW_TIME and @time_elapsed < (SHOW_TIME + ENCORE_WAIT_TIME)
        self.last_state = "encore_wait_state"
        self.state_updated_at = self.state_updated_at + SHOW_TIME
      elsif @time_elapsed > (SHOW_TIME + ENCORE_WAIT_TIME)  
        self.last_state = "empty_state"
        switch_dwelling_id(get_level)
        self.state_updated_at = self.state_updated_at + SHOW_TIME + ENCORE_WAIT_TIME
      else
      end      
    elsif self.last_state == "encore_state" 
      if @time_elapsed > ENCORE_TIME
        self.last_state = "empty_state"
        switch_dwelling_id(get_level)
        self.state_updated_at = self.state_updated_at + ENCORE_TIME
      else
      end
    elsif self.last_state == "show_wait_state"
      if show_button_clicked == "true"
        self.last_state = "show_state"
        self.state_updated_at = Time.new
      end  
    else
               
    end     
  end
  
  def update_fancount(new_fans)
    self.fancount += new_fans  
  end
  
  def switch_dwelling_id(level) 
    array = Array.new     
    Dwelling.find_each(:conditions => ["unlocks_at = ? and id != ?", level.order, self.dwelling_id], :select => 'id') do |dwelling|
      array.push dwelling
    end  
    
    rand_id = (rand(array.length - 1)).floor
    
    if rand_id >= 0
      selected_dwelling_id = (array[rand_id]).id
    else
      selected_dwelling_id = self.dwelling_id
    end
      
    self.dwelling_id = selected_dwelling_id
    self.fancount = 0
    self.save
  end
  
  def get_level
    user = User.find(self.user_id)
    level = Level.find(user.level_id)
    return level
  end  
  
  def get_random
    if (c = count) != 0
      find(:first, :offset => rand(c))
    end
  end    
  
  def update_boothcount(new_fans, array)
    OwnedStructure.find_each(:conditions => ["owned_dwelling_id = ?", self.id]) do |owned_structure|
      structure = Structure.find(owned_structure.structure_id)
      if structure.structure_type == "Booth"
        owned_structure.update_inventory_count(self)
        hash = Hash.new
        hash["instance"] = owned_structure
        hash["already_loaded"] = true
        hash["model"] = "owned_structure"
        hash["method"] = "update_boothcount"
        array.push hash
      end  
    end
  end    
  
  def get_time_elapsed(time_since)
    time = Time.new
    time_elapsed = time - time_since
    time_elapsed
  end 
   
end
