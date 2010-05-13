class Structure < ActiveRecord::Base
  has_one :booth_structure
  
  LISTENER_CREDITS = 50
  STATION_CREDITS_XP_MULTIPLIER = 3
  
  def getStationCreditsMultiplier
    return STATION_CREDITS_XP_MULTIPLIER
  end  
  
  def getListenerCredits
    return LISTENER_CREDITS
  end  
  
end
