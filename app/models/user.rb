class User < ActiveRecord::Base
  has_many :creatures
  has_many :owned_layerables
  has_many :owned_thingers
  has_many :owned_usables
  has_many :owned_dwellings
  has_many :owned_structures
  
  SELLBACK_FRACTION = 0.5
  
  def add_credits(to_add)
    self.credits += to_add
    self.save    
  end
  
  def decrement_credits(to_remove)
     self.credits -= to_remove
     self.save    
   end  
  
  def add_xp(to_add)
    self.xp += to_add
    update_level
    self.save
  end
  
  def add_bonus(to_add, type)
    if type == "xp"
      add_xp(to_add)
    elsif type == "credits"
      add_credits(to_add)
    elsif type == "music_credits"
      self.music_credits += to_add
    elsif type == "fan_credits"    
      self.fan_credits += to_add
    elsif type == "premium_credits"
      self.premium_credits += to_add
    end  
    self.save      
  end
  
  def update_level
    total_xp_diff = 0
    levels = Level.all(:order => "rank ASC")
    i = 0
    levels.each do |level|
      total_xp_diff = total_xp_diff + level.xp_diff
      logger.debug("levelrank:" + level.rank.to_s)  
      logger.debug("xpdiff:" + total_xp_diff.to_s)                          
      if total_xp_diff >= self.xp
        self.level_id = levels[i-1].rank
        self.save
        break
      elsif levels.length == i - 1
        self.level_id = levels[i-1].rank
        self.save
      end
      i = i + 1
    end    
  end    
  
  def add_hash(array, method, already_loaded)
    hash = Hash.new
    logger.debug(self.level_id.to_s)
    hash["instance"] = self
    hash["already_loaded"] = already_loaded
    hash["model"] = "user"
    hash["method"] = method
    array.push hash    
  end  
    
end
