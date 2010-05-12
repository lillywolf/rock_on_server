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
    
end
