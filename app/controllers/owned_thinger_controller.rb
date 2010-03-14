class OwnedThingerController < ApplicationController

  def find_by_user_id
    @array = Array.new
    OwnedThinger.find_each(:conditions => ["user_id = ?", params[:user_id]]) do |owned_thinger|
      hash = Hash.new
      thinger_reference = owned_thinger.thinger_id 
      hash["belongs_to"] = ["thinger"]
      hash["belongs_to_id"] = [thinger_reference]
      hash["instance"] = owned_thinger
      @array.push hash            
    end            
    render :json => @array.to_json         
  end  
  
end
