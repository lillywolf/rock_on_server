class BoothStructure < ActiveRecord::Base
  
  BOOTH_CREDITS_XP_MULTIPLIER = 2
  
  def getBoothCreditsMultiplier
    return BOOTH_CREDITS_XP_MULTIPLIER
  end  
  
end
