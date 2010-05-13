class User < ActiveRecord::Base
  has_many :creatures
  has_many :owned_layerables
  has_many :owned_thingers
  has_many :owned_usables
  has_many :owned_dwellings
  has_many :owned_structures
  
  def add_credits(to_add)
    self.credits += to_add
    self.save    
  end
  
  def add_xp(to_add)
    self.xp += to_add
    update_level
    self.save
  end
  
  def update_level
    array = Array.new
    total_xp_diff = 0
    levels = Level.all(:order => "rank ASC")
    levels.each do |level|
      total_xp_diff += level.xp_diff
      logger.debug(total_xp_diff.to_s)
      if total_xp_diff >= self.xp
        logger.debug(level.rank.to_s)
        self.level_id = level.id
        self.save
        break
      end
    end    
  end    
  
  def add_hash(array, method, already_loaded)
    hash = Hash.new
    hash["instance"] = self
    hash["already_loaded"] = already_loaded
    hash["model"] = "user"
    hash["method"] = method
    array.push hash    
  end  
    
end
